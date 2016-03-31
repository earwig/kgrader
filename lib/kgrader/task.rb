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
      puts "[grading]"
      puts "course     => #{@course.name}"
      puts "semester   => #{@semester}"
      puts "assignment => #{@assignment.name}"
      puts "students   => #{students.join ', '}"
      puts "due        => #{due}"
      puts "fetch      => #{fetch}"
      puts "regrade    => #{regrade}"
      puts

      fetch_students students if fetch
    end

    def commit(options = {})
      students = @students
      students &= options[:students] unless options[:students].nil?

      # TODO
      puts "[committing]"
      puts "course     => #{@course.name}"
      puts "semester   => #{@semester}"
      puts "assignment => #{@assignment.name}"
      puts "students   => #{students.join ', '}"
    end

    private
    def fetch_students(students)
      students.each do |student|
        @course.backend.fetch @semester, @assignment.id, student
      end
    end
  end
end
