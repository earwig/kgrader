require 'fileutils'
require 'timeout'

module KGrader
  module Runtime
    MAX_COLS = 79

    def testcase(options)
      puts " running test: #{File.basename $0} ".center MAX_COLS, '='

      begin
        Timeout::timeout options[:alarm] { yield }
      rescue Timeout::Error
        comment "timeout"
        grade 0
      end

      comment "autograde error (no grade reported); please contact staff"
      grade 0
    end

    def grade(score)
      IO.new(3).write score
      puts " done ".center MAX_COLS, '-'
      puts
      exit
    end

    def comment(text)
      puts "comment: #{text}"
      IO.new(4).write text + "\n"
    end

    def salt
      ARGV[0]
    end

    def getpath(filename)
      File.join File.dirname($0), filename
    end
  end
end
