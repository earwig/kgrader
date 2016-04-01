require 'open3'

module KGrader::Backend
  class SVN

    def initialize(filesystem, course, config)
      @fs = filesystem
      @course = course
      @config = config
    end

    def revision(repo)
      # TODO
      -1
    end

    def clone(repo, semester, assignment, student)
      url = get_url semester, assignment, student
      run 'checkout', '--ignore-externals', url, repo
    end

    def update(repo)
      run 'update', '--ignore-externals', '--accept', 'tf', repo
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
