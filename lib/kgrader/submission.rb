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
        rewind due
        self.status = revision == oldrev ? :graded : :ungraded
      end
    end

    def grade
      # TODO
      # self.status = :graded
    end

    private
    def statusfile
      File.join @root, "status.txt"
    end

    def repo
      File.join @root, "repo"
    end

    def revision
      @course.backend.revision repo
    end

    def rewind(date)
      # TODO
    end
  end
end
