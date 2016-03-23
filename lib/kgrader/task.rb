module KGrader
  class Task

    def initialize(filesystem, course, semester, assignment)
      @fs = filesystem
      @course = course
      @semester = semester
      @assignment = assignment
    end

    def grade(options = {})
      # TODO
      puts "Grading #{@course.name}:#{@semester} assignment #{@assignment}..."
      puts "- options: #{options}"
    end

    def commit(options = {})
      # TODO
      puts "Committing #{@course.name}:#{@semester} assignment #{@assignment}..."
      puts "- options: #{options}"
    end
  end
end
