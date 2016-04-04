module KGrader
  class CLI

    def initialize(dir)
      @fs = Filesystem.new dir
    end

    def list(course, semester)
      if semester
        puts Course.new(@fs, course).roster(semester).students
      elsif course
        list_course course, 0
      else
        @fs.courses.each do |name|
          puts "course: #{name}"
          list_course name, 1
        end
      end
    end

    def roster(course, semester, rosterfile)
      course = Course.new(@fs, course)
      semester ||= course.current_semester
      course.roster(semester).load rosterfile
    end

    def grade(course, semester, assignment, students = nil, options = {})
      course = Course.new(@fs, course)
      semester ||= course.current_semester
      course.task(semester, assignment, students).grade options
    end

    def commit(course, semester, assignment, students = nil)
      course = Course.new(@fs, course)
      semester ||= course.current_semester
      course.task(semester, assignment, students).commit
    end

    def clean
      clear_jail
      # TODO: also purge uncommitted grades: set all graded to ungraded and delete all pending files
    end

    def clobber
      puts "clobbering means deleting local student repos and roster files"
      print "are you sure? [y/N] "
      abort "aborted" unless ['y', 'yes'].include? STDIN.gets.strip.downcase

      clear_jail
      clear_desk
    end

    private
    def list_course(name, indent = 0)
      course = Course.new(@fs, name)
      pad = '  ' * indent

      puts "#{pad}rosters:"
      course.rosters.each do |roster|
        puts "#{pad}  - #{roster.semester} (#{roster.students.size} students)"
      end

      puts "#{pad}assignments:"
      course.assignments.each do |assignment|
        puts "#{pad}  - #{assignment.name}"
      end
    end

    def clear_jail
      FileUtils.rm_rf @fs.jail
    end

    def clear_desk
      FileUtils.rm_rf Dir[File.join @fs.desk, '*', '']
    end
  end
end
