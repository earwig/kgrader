module KGrader
  class Jail

    def initialize(root)
      @root = root
      @salt = nil
    end

    def reset
      FileUtils.rm_rf @root
    end

    def init
      FileUtils.mkdir_p @root
      @salt = rand(100000000).to_s
    end

    def stage(source, target)
      FileUtils.cp source, File.join(@root, target)
    end

    def exec(command, logpath)
      pid = execute command, logpath
      Process.waitpid pid, 0
      $?.exited? && $?.exitstatus == 0
    end

    def run_test(script, logpath)
      grade_rd, grade_wr = IO.pipe
      cmt_rd, cmt_wr = IO.pipe

      command = ['ruby', '-r', '../lib/kgrader/runtime.rb', script, @salt]
      pid = execute command, logpath do |options|
        [grade_rd, cmt_rd].each &:close
        options[3] = grade_wr
        options[4] = cmt_wr
      end

      [grade_wr, cmt_wr].each &:close
      Process.waitpid pid, 0

      cmt_rd.read.split("\n").each { |cmt| yield cmt } if block_given?
      grade = grade_rd.read.strip.to_i
      [grade_rd, cmt_rd].each &:close
      grade
    end

    private
    def execute(command, logpath)
      Process.fork do
        fp = File.open(logpath, 'a')
        Dir.chdir @root
        options = {
          :in => :close, :out => fp, :err => fp, :close_others => true,
          :rlimit_nproc => 32
        }
        yield options if block_given?
        Process.exec *command, options
      end
    end
  end
end
