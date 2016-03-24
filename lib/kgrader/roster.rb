module KGrader
  class Roster
    attr_reader :semester

    def initialize(filesystem, course, semester)
      @fs = filesystem
      @course = course
      @semester = semester
    end

    def load(filename)
      # TODO
      puts "Loading roster for #{@course.name}:#{@semester} from [#{filename}]..."
    end

    def students
      # TODO
      ["ksmith12"]
    end
  end
end
