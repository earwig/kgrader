module KGrader
  class CLI

    def initialize(dir)
      @dir = dir
    end

    def list
      # TODO
      puts "[list]"
    end

    def roster(course, semester, rosterfile)
      # TODO
      puts "[installing roster: c=#{course} s=#{semester} rf=#{rosterfile}]"
    end

    def grade(course, semester, assignment, options = {})
      # TODO
      puts "[grading c=#{course} s=#{semester} a=#{assignment}]"
      puts "  - [students=#{options[:students].inspect}]"
      puts "  - [due=#{options[:due].inspect}]"
      puts "  - [fetch=#{options.fetch(:fetch, true).inspect}]"
      puts "  - [regrade=#{options.fetch(:regrade, false).inspect}]"
    end

    def commit(course, semester, assignment, options = {})
      # TODO
      puts "[committing c=#{course} s=#{semester} a=#{assignment}]"
      puts "  - [students=#{options[:students].inspect}]"
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
      jail_dir = File.join(@dir, 'jail')
      FileUtils.rm_rf jail_dir
      FileUtils.mkdir jail_dir
      FileUtils.touch File.join(jail_dir, '.gitkeep')
    end

    def reset_desk
      desk_dir = File.join(@dir, 'desk')
      FileUtils.rm_rf Dir.glob(File.join(desk_dir, '*', ''))
    end
  end
end
