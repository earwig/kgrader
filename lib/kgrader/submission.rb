module KGrader
  class Submission
    attr_reader :course, :semester, :assignment, :student

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

    def grade
      grade_prep
      stage
      build
      test
      save
      grade_post
      @summary
    end

    def commit
      if status == :graded && File.exists?(pendingfile)
        target = File.join(repo, @assignment.report)
        message = @assignment.commit_message @student
        FileUtils.cp gradefile, target
        @course.backend.commit repo, message, target
        FileUtils.rm pendingfile
      end
    end

    private
    def repo
      File.join @root, 'repo'
    end

    def statusfile
      File.join @root, 'status.txt'
    end

    def gradefile
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

    def grade_prep
      @failure = false
      @comments = []
      @summary = nil
      @tests = []

      self.status = :ungraded
      FileUtils.rm_f [buildlog, testlog]
      @fs.jail.reset
      @fs.jail.init

      @assignment.tests.each do |test|
        @tests.push({ :name => test[:name], :max => test[:max], :score => 0 })
      end
    end

    def stage
      @assignment.manifest[:provided].each do |entry|
        @fs.jail.stage entry[:path], entry[:name]
      end
      @assignment.manifest[:graded].each do |entry|
        @fs.jail.stage File.join(repo, entry[:name]), entry[:name]
      end
    end

    def build
      @assignment.build_steps.each do |command|
        return build_failure unless @fs.jail.exec command, buildlog
      end
    end

    def test
      return if @failure
      @assignment.tests.each do |test|
        # TODO: execute script in jail and update @test/@comments; out testlog
      end
    end

    def save
      File.write gradefile, generate_report
      FileUtils.touch pendingfile
    end

    def grade_post
      # self.status = :graded  # TODO: uncomment
      # @fs.jail.reset  # TODO: uncomment
      @summary = generate_summary unless @summary
    end

    def build_failure
      @failure = true
      @comments.push "failed to compile"
      @summary = "#{format_points 0, max_score}: failed to compile"
    end

    def generate_report
      # TODO
      @tests
      @assignment.extra_comments
    end

    def generate_summary
      tests = @tests.each do |test|
        "#{test[:score].to_s.rjust get_span(test[:max])}/#{test[:max]}"
      end.join ', '
      "#{format_points score, max_score}: #{tests}"
    end

    def score
      @tests.reduce(0) { |sum, t| sum + t[:score] }
    end

    def max_score
      @tests.reduce(0) { |sum, t| sum + t[:max] }
    end

    def format_points(score, max)
      percent = (score.to_f * 100 / max).round.to_s.rjust 3
      span = get_span max
      "#{percent}% (#{score.to_s.rjust span}/#{max.to_s.rjust span})"
    end

    def get_span(max)
      (Math.log10(max) + 1).to_i
    end
  end
end
