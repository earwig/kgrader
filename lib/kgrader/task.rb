module KGrader
  class Task

    def initialize(filesystem, course, semester, assignment)
      @fs = filesystem
      @course = course
      @semester = semester
      @assignment = assignment
      @roster = @course.roster @semester
    end

    def grade(options = {})
      students = @roster.students
      students &= options[:students] unless options[:students].nil?

      # TODO
      puts "Grading #{@course.name}:#{@semester} assignment #{@assignment}..."
      puts "- options: #{options}"
      puts "- students: #{students.inspect}"
    end

    def commit(options = {})
      # TODO
      puts "Committing #{@course.name}:#{@semester} assignment #{@assignment}..."
      puts "- options: #{options}"
    end
  end
end
