module KGrader
  class Assignment
    attr_reader :name

    def initialize(filesystem, course, name)
      @fs = filesystem
      @course = course
      @name = name

      @config = @fs.load @fs.assignment(@course.name, @name)
    rescue FilesystemError
      raise AssignmentError, "unknown assignment: #{name}"
    end

    def id
      @config['id'] || @name
    end
  end
end
