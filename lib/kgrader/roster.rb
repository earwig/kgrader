module KGrader
  class Roster

    def initialize(filesystem, course, semester)
      @fs = filesystem
      @course = course
      @semester = semester
    end

    def load(filename)
      # TODO
      puts "Loading roster for #{@course.name}:#{@semester} from [#{filename}]..."
    end
  end
end
