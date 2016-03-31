module KGrader
  class Course
    attr_reader :name

    def initialize(filesystem, name)
      @fs = filesystem
      @name = name

      @config = @fs.load @fs.course_config(@name)
      @rosters = {}
      @assignments = {}
    rescue FilesystemError
      raise CourseError, "unknown or invalid course: #{name}"
    end

    def roster(semester)
      @rosters[semester] ||= Roster.new @fs, self, semester
    end

    def assignment(name)
      @assignments[name] ||= Assignment.new @fs, self, name
    end

    def task(semester, assignment)
      Task.new @fs, self, semester, assignment
    end

    def rosters
      @fs.semesters(@name).map! { |semester| roster semester }
    end

    def assignments
      @fs.assignments(@name).map! { |name| assignment name }
    end

    def current_semester
      KGrader::current_semester @config['semesters']
    end
  end
end
