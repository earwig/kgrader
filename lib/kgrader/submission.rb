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
      self.status = :ungraded
      stage
      build
      test
      save
      # self.status = :graded  # UNCOMMENT
      # @fs.jail.reset         # UNCOMMENT
      # TODO: return grade summary string
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

    def stage
      @fs.jail.reset
      @fs.jail.init

      @assignment.manifest[:provided].each do |entry|
        @fs.jail.stage entry[:path], entry[:name]
      end
      @assignment.manifest[:graded].each do |entry|
        @fs.jail.stage File.join(repo, entry[:name]), entry[:name]
      end
    end

    def build
      @assignment.build_steps.each do |command|
        @fs.jail.exec command
      end
    end

    def test
      @assignment.tests.each do |script|
        # TODO: execute script in jail
      end
    end

    def save
      # TODO: save gradefile
      FileUtils.touch pendingfile
    end
  end
end
