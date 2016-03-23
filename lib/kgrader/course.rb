require_relative 'roster'
require_relative 'task'

module KGrader
  class Course
    attr_reader :name

    def initialize(filesystem, name)
      @fs = filesystem
      @name = name
      @config = @fs.load @fs.course_config(@name)
    end

    def roster(semester)
      # TODO: cache
      Roster.new @fs, self, semester
    end

    def task(semester, assignment)
      # TODO: cache
      Task.new @fs, self, semester, assignment
    end
  end
end
