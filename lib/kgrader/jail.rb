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

    def exec(command)
      pid = Process.fork do
        Dir.chdir @root
        # TODO: rlimit in exec, umask?
        Process.exec command
      end
      Process.waitpid pid, 0
    end
  end
end
