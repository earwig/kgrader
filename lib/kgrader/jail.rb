module KGrader
  class Jail

    def initialize(root)
      @root = root
    end

    def reset
      FileUtils.rm_rf @root
    end

    def init
      FileUtils.mkdir_p @root
    end

    def stage(source, target)
      FileUtils.cp source, File.join(@root, target)
    end

    def exec(command, logpath)
      pid = Process.fork do
        fp = File.open(logpath, 'w+')
        Dir.chdir @root
        # TODO: rlimit in exec, umask?
        Process.exec command, :in => :close, :out => fp, :err => fp,
          :close_others => true
      end
      Process.waitpid pid, 0
      $?.exited? && $?.exitstatus == 0
    end
  end
end
