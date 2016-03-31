module KGrader
  class Task

    def initialize(filesystem, course, semester, assignment)
      @fs = filesystem
      @course = course
      @semester = semester

      @assignment = @course.assignment assignment
      @students = @course.roster(@semester).students
    end

    def grade(options = {})
      students = @students
      students &= options[:students] unless options[:students].nil?

      due = options.fetch(:due, Time.now)
      fetch = options.fetch(:fetch, true)
      regrade = options.fetch(:regrade, false)

      # TODO
      puts "Grading #{@course.name}:#{@semester} assignment #{@assignment.name}..."
      puts "- students: #{students.inspect}"
      puts "- due:      #{due}"
      puts "- fetch:    #{fetch}"
      puts "- regrade:  #{regrade}"
    end

    def commit(options = {})
      students = @students
      students &= options[:students] unless options[:students].nil?

      # TODO
      puts "Committing #{@course.name}:#{@semester} assignment #{@assignment.name}..."
      puts "- students: #{students.inspect}"
    end
  end
end
