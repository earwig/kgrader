require_relative 'course'
require_relative 'filesystem'

module KGrader
  class CLI

    def initialize(dir)
      @fs = Filesystem.new dir
    end

    def list
      # TODO
      puts "[list]"
    end

    def roster(course, semester, rosterfile)
      Course.new(@fs, course).roster(semester).load rosterfile
    end

    def grade(course, semester, assignment, options = {})
      # TODO
      # need to get default semester...
      semester ||= 'DEFAULT'
      task = Course.new(@fs, course).task semester, assignment
      task.grade options
    end

    def commit(course, semester, assignment, options = {})
      # TODO
      semester ||= 'DEFAULT'
      task = Course.new(@fs, course).task semester, assignment
      task.commit options
    end

    def clean
      # TODO: also purge uncommitted grades
      reset_jail
    end

    def clobber
      # TODO: confirm
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
