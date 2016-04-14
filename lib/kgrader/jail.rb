module KGrader
  class Jail

    def initialize(root)
      @root = root
    end

    def init
      FileUtils.mkdir_p @root
    end

    def reset
      FileUtils.rm_rf @root
    end

    def stage(source, target)
      puts "[chroot::stage] #{source} -> (jail)/#{target}"
    end
  end
end
