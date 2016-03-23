require 'yaml'

module KGrader
  class Filesystem

    def initialize(root)
      @root = root
    end

    def course(name)
      File.join @root, 'spec', name
    end

    def course_config(name)
      File.join course(name), '_config.yml'
    end

    def courses
      Dir[File.join @root, 'spec', '*', ''].each { |fn| File.basename fn }
    end

    def desk
      File.join @root, 'desk'
    end

    def jail
      File.join @root, 'jail'
    end

    def load(path)
      case File.extname path
      when '.yml', '.yaml'
        YAML.load File.read(path)
      when '.csv'
        # TODO
      end
    end
  end
end
