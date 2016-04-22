require 'nokogiri'
require 'open3'

module KGrader::Backend
  class SVN

    def initialize(filesystem, course, config)
      @fs = filesystem
      @course = course
      @config = config
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
      # TODO
      # run 'commit', '-m', message, *paths.map { |fn| File.join repo, fn }
    end

    def commit_date(repo)
      xml = Nokogiri::XML run('log', '--xml', '-l', '1', repo).first
      Time.parse xml.css('logentry date').text
    end

    private
    def run(*cmd)
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
