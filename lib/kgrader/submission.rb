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
      # TODO:
      # self.status = :ungraded
      stage
      # [grade the stuff]
      # [save report to gradefile]
      # @fs.reset_jail
      # FileUtils.touch pendingfile
      # self.status = :graded
      # return grade summary string

      sleep rand / 2
      '100%'
    end

    def commit
      # TODO:
      # if status == :graded && File.exists? pendingfile
      #   [copy gradefile to repo]
      #   @course.backend.commit repo, <message>, <gradefile path>
      #   FileUtils.rm pendingfile
      # end

      sleep rand / 2
      nil
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
      @fs.reset_jail
      FileUtils.mkdir_p @fs.jail

      # puts
      # @assignment.manifest[:provided].each { |fn| p fn }
      # abort

      # p @assignment.manifest[:provided], @assignment.manifest[:graded], @assignment.manifest[:report]

      # copytree files matching manifest from student submission
      # use assignment.stage
    end
  end
end
