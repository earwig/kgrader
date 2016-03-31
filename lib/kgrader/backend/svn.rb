module KGrader::Backend
  class SVN

    def initialize(filesystem, config)
      @fs = filesystem
      @config = config
    end

    def fetch(semester, assignment, student)
      url = @config['url'] % {
        :semester => semester, :assignment => assignment, :student => student }

      # TODO
      puts "[fetching #{student}: #{url}]"
    end
  end
end
