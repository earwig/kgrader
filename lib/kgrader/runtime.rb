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
      puts " done ".center MAX_COLS, '-'
    end

    def grade(score)
      IO.new(3).write score
      exit
    end

    def comment(text)
      IO.new(4).write text + "\n"
    end

    def shake
      ARGV[0]
    end
  end
end
