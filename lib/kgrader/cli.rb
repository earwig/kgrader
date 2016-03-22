module KGrader
  class CLI

    def initialize(dir)
      @dir = dir
    end

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
