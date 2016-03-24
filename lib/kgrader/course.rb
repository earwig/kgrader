require_relative 'roster'
require_relative 'task'

module KGrader
  class Course
    attr_reader :name

    def initialize(filesystem, name)
      @fs = filesystem
      @name = name

      @config = @fs.load @fs.course_config(@name)
      @rosters = {}
    end

    def roster(semester)
      @rosters[semester] ||= Roster.new @fs, self, semester
    end

    def task(semester, assignment)
      Task.new @fs, self, semester, assignment
    end

    def rosters
      @fs.semesters(@name).map! { |semester| roster semester }
    end

    def assignments
      @fs.assignments @name
    end

    def current_semester
      case @config['semesters']
      when 'faspYY'
        KGrader::season + DateTime.now.strftime('%y')
      when 'faspYYYY'
        KGrader::season + DateTime.now.strftime('%Y')
      end
    end
  end
end
