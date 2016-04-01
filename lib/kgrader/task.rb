module KGrader
  class Task

    def initialize(filesystem, course, semester, assignment)
      @fs         = filesystem
      @course     = course
      @semester   = semester

      @assignment = @course.assignment assignment
      @students   = @course.roster(@semester).students
    end

    def grade(options = {})
      submissions = get_submissions options[:students]
      due = options.fetch(:due, Time.now)
      fetch = options.fetch(:fetch, true)
      regrade = options.fetch(:regrade, false)

      count = submissions.count
      puts "[grading #{count} student#{'s' if count != 1}]"

      submissions.each do |sub|
        unless sub.exists?
          puts "[init #{sub.student}]"
          sub.create
        end
      end

      if fetch
        submissions.each do |sub|
          puts "[fetch #{sub.student}]"
          sub.fetch due
        end
      end

      submissions.each do |sub|
        sub.status = :ungraded if regrade
        if sub.status == :ungraded
          puts "[grade #{sub.student}]"
          sub.grade
        end
      end
    end

    def commit(options = {})
      submissions = get_submissions options[:students]

      # TODO
      puts "[committing]"
      puts "course     => #{@course.name}"
      puts "semester   => #{@semester}"
      puts "assignment => #{@assignment.name}"
      puts "students   => #{submissions.map { |sub| sub.student }.join ', '}"
    end

    private
    def get_submissions(students)
      students.nil? ? (students = @students) : (students &= @students)
      students.map do |student|
        Submission.new @fs, @course, @semester, @assignment, student
      end
    end
  end
end
