require_relative 'course'
require_relative 'filesystem'

module KGrader
  class CLI

    def initialize(dir)
      @fs = Filesystem.new dir
    end

    def list
      @fs.courses.each do |name|
        puts "course: #{name}"
        course = Course.new(@fs, name)

        puts "  rosters:"
        course.rosters.each do |roster|
          puts "    - #{roster.semester} (#{roster.students.size} students)"
        end

        puts "  assignments:"
        course.assignments.each do |assignment|
          puts "    - #{assignment}"
        end
      end
    end

    def roster(course, semester, rosterfile)
      Course.new(@fs, course).roster(semester).load rosterfile
    end

    def grade(course, semester, assignment, options = {})
      course = Course.new @fs, course
      semester ||= course.current_semester
      course.task(semester, assignment).grade options
    end

    def commit(course, semester, assignment, options = {})
      course = Course.new @fs, course
      semester ||= course.current_semester
      course.task(semester, assignment).commit options
    end

    def clean
      # TODO: also purge uncommitted grades
      reset_jail
    end

    def clobber
      puts "clobbering means deleting local student repos and roster files"
      print "are you sure? [y/N] "
      abort "aborted" unless ['y', 'yes'].include? STDIN.gets.strip.downcase

      reset_jail
      reset_desk
    end

    private
    def reset_jail
      FileUtils.rm_rf @fs.jail
      FileUtils.mkdir @fs.jail
      FileUtils.touch File.join(@fs.jail, '.gitkeep')
    end

    def reset_desk
      FileUtils.rm_rf Dir[File.join @fs.desk, '*', '']
    end
  end
end
