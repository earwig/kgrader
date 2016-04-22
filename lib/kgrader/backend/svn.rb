require 'io/console'
require 'nokogiri'
require 'open3'

module KGrader::Backend
  class SVN

    def initialize(filesystem, course, config)
      @fs = filesystem
      @course = course
      @config = config
      @password = nil
    end

    def prepare(semester, assignment)
      return unless @config['verify']
      url = @config['verify'] % {
        :semester => semester,
        :assignment => assignment
      }

      status = run('list', '--non-interactive', url)[1]
      if status.exited? && status.exitstatus != 0
        print "svn: password: "
        @password = STDIN.noecho(&:gets).chomp
      end
    end

    def revision(repo)
      xml = Nokogiri::XML run('log', '--xml', '-l', '1', repo).first
      xml.css('logentry').attr('revision').value.to_i
    end

    def clone(repo, semester, assignment, student)
      url = get_url semester, assignment, student
      run 'checkout', '--ignore-externals', url, repo
    end

    def update(repo, revision = nil)
      args = 'update', '--ignore-externals', '--accept', 'tf'
      args.push "-r#{revision}" unless revision.nil?
      run *args, repo
    end

    def log(repo)
      xml = Nokogiri::XML run('log', '--xml', repo).first
      xml.css('logentry').map do |elem|
        { :rev  => elem.attr('revision').to_i,
          :date => Time.parse(elem.css('date').text) }
      end
    end

    def commit(repo, message, paths = nil)
      run 'commit', '-m', message, *paths.map { |fn| File.join repo, fn }
    end

    def commit_date(repo)
      xml = Nokogiri::XML run('log', '--xml', '-l', '1', repo).first
      Time.parse xml.css('logentry date').text
    end

    private
    def run(*cmd)
      if @password
        cmd.unshift '--password'
        cmd.unshift @password
      end
      Open3.capture2e('svn', *cmd)
    end

    def get_url(semester, assignment, student)
      @config['url'] % {
        :semester   => semester,
        :assignment => assignment,
        :student    => student
      }
    end
  end
end
