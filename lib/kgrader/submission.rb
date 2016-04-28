module KGrader
  class Submission
    attr_reader :course, :semester, :assignment, :student
    MAX_COLS = 79

    def initialize(filesystem, course, semester, assignment, student)
      @fs         = filesystem
      @course     = course
      @semester   = semester
      @assignment = assignment
      @student    = student

      @root = @fs.submission @course.name, @semester, @assignment.name, student
      @status = nil
    end

    def status
      @status ||= @fs.load(statusfile).to_sym
    end

    def status=(new_status)
      File.write statusfile, new_status
      @status = new_status
    end

    def exists?
      File.exists? statusfile
    end

    def create
      FileUtils.mkdir_p @root
      self.status = :init
      nil
    end

    def fetch(due)
      if status == :init
        @course.backend.clone repo, @semester, @assignment.id, @student
        rewind due
        self.status = :ungraded
      else
        oldrev = revision if status == :graded
        self.status = :fetching
        @course.backend.update repo
        newrev = rewind due
        self.status = newrev == oldrev ? :graded : :ungraded
      end
      nil
    end

    def grade(superscore = false)
      grade_prep superscore
      stage
      build
      test
      save
      grade_post
      @summary
    end

    def commit
      if status == :graded && File.exists?(pendingfile)
        message = @assignment.commit_message @student
        FileUtils.cp gradereport, File.join(repo, @assignment.report)
        @course.backend.commit repo, message, @assignment.report
        FileUtils.rm pendingfile
      end
      nil
    end

    # -------------------------------------------------------------------------

    private
    def repo
      File.join @root, 'repo'
    end

    def statusfile
      File.join @root, 'status.txt'
    end

    def gradefile
      File.join @root, 'grade.json'
    end

    def gradereport
      File.join @root, 'grade.txt'
    end

    def pendingfile
      File.join @root, 'pending'
    end

    def buildlog
      File.join @root, 'build.log'
    end

    def testlog
      File.join @root, 'test.log'
    end

    def revision
      @course.backend.revision repo
    end

    def rewind(date)
      log = @course.backend.log repo
      target = log.find { |commit| commit[:date] <= date }
      if target.nil?
        raise SubmissionError, "no commits before due date: #{student}"
      end

      rev = target[:rev]
      @course.backend.update repo, rev
      rev
    end

    # -------------------------------------------------------------------------

    def grade_prep(superscore)
      @done = false
      @failed = false
      @changed = !superscore || self.status == :ungraded
      @summary = nil
      @tests = @assignment.tests.clone.each do |test|
        test[:score] = 0
        test[:comments] = []
      end
      load_gradefile if superscore

      if superscore && @tests.all? { |test| test[:score] == test[:max] }
        @done = true
        return
      end

      self.status = :ungraded
      archive_logs superscore
      @fs.jail.reset
      @fs.jail.init
    end

    def stage
      return if @done
      @assignment.manifest[:provided].each do |entry|
        @fs.jail.stage entry[:path], entry[:name]
      end
      @assignment.manifest[:graded].each do |entry|
        @fs.jail.stage File.join(repo, entry[:name]), entry[:name]
      end
    end

    def build
      return if @done
      @assignment.build_steps.each do |command|
        return build_failure unless @fs.jail.exec command, buildlog
      end
    end

    def test
      return if @done
      @tests.each { |test| run_test test }
    end

    def save
      if @changed
        File.write gradefile, generate_gradefile
        File.write gradereport, generate_report
        FileUtils.touch pendingfile
      end
    end

    def grade_post
      self.status = :graded
      @fs.jail.reset
      @summary = generate_summary
    end

    # -------------------------------------------------------------------------

    def archive_logs(superscore)
      logs = [buildlog, testlog]
      if superscore
        logs.select { |log| File.exists? log }.each do |log|
          File.rename log, "#{log}.#{Time.now.strftime('%Y%m%d%H%M%S')}"
        end
      else
        FileUtils.rm_f logs
      end
    end

    def build_failure
      @done = true
      @failed = true
    end

    def run_test(test)
      return if test[:score] == test[:max]  # Can't superscore the max score

      test[:depends].each do |depname|
        dep = @tests.find { |t| t[:name] == depname }
        if !dep.nil? && dep[:score] == 0
          test[:comments] = [test[:depfail]]
          return
        end
      end

      score, comments = @fs.jail.run_test test[:script], testlog
      if score > test[:score]
        test[:score] = score
        test[:comments] = comments
        @changed = true
      end
    end

    def load_gradefile
      begin
        data = @fs.load gradefile
      rescue FilesystemError
        return
      end
      data.each do |name, fields|
        test = @tests.find { |t| t[:name] == name }
        test[:score], test[:comments] = fields
      end
    end

    def generate_gradefile
      data = @tests.inject({}) do |hash, test|
        hash[test[:name]] = [test[:score], test[:comments]]
        hash
      end
      JSON.generate data
    end

    def generate_report
      header = "#{assignment.title} Grade Report for #{student}"
      header = header.center(MAX_COLS).rstrip
      hr1 = '-' * MAX_COLS
      hr2 = '=' * MAX_COLS

      metadata = [
        "commit revision: #{revision}",
        "commit date:     #{format_time @course.backend.commit_date(repo)}",
        "grade date:      #{format_time Time.now}"
      ]
      version = KGrader.version
      metadata.push "grader version:  #{version}" if version
      metadata = metadata.join "\n"

      tests = "tests:\n" + @tests.map do |test|
        score = format_points(test[:score], test[:max], max_score)
        justify_both "    - #{test[:name]}", score
      end.join("\n")

      total = justify_both "total:", format_points(score, max_score)
      comments = generate_comments

      [header, hr2, metadata, hr1, tests, hr1, total, hr1, comments].join "\n"
    end

    def generate_summary
      if !@changed
        line = "no change"
      elsif @failed
        line = "failed to compile"
      else
        line = @tests.map do |test|
          "#{test[:score].to_s.rjust get_span(test[:max])}/#{test[:max]}"
        end.join ', '
      end
      "#{format_points score, max_score}: #{line}"
    end

    def score
      @tests.reduce(0) { |sum, t| sum + t[:score] }
    end

    def max_score
      @tests.reduce(0) { |sum, t| sum + t[:max] }
    end

    def generate_comments
      comments = []
      comments.push "failed to compile" if @failed
      @tests.each do |test|
        test[:comments].each { |cmt| comments.push "#{test[:name]}: #{cmt}" }
      end
      comments.concat @assignment.extra_comments

      return "" if comments.empty?
      "comments:\n" + comments.map { |cmt| "    - #{cmt}\n" }.join
    end

    def format_points(score, max, span_max = nil)
      percent = (score.to_f * 100 / max).round.to_s.rjust 3
      span = get_span(span_max || max)
      "#{percent}% (#{score.to_s.rjust span}/#{max.to_s.rjust span})"
    end

    def justify_both left, right
      "#{left}#{right.rjust MAX_COLS - left.length}"
    end

    def get_span(max)
      (Math.log10(max) + 1).to_i
    end

    def format_time(time)
      time.localtime.strftime "%H:%M, %b %d, %Y %Z"
    end
  end
end
