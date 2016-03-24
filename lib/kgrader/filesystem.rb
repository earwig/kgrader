require 'yaml'

module KGrader
  class Filesystem

    def initialize(root)
      @root = root
    end

    def desk
      File.join @root, 'desk'
    end

    def jail
      File.join @root, 'jail'
    end

    def spec
      File.join @root, 'spec'
    end

    def course(name)
      File.join spec, name
    end

    def course_config(name)
      File.join course(name), '_config.yml'
    end

    def courses
      Dir[File.join spec, '*', ''].map! { |fn| File.basename fn }
    end

    def assignments(course)
      Dir[File.join spec, course, '*', '_config.yml'].map! do |fn|
        File.basename File.dirname fn
      end
    end

    def semesters(course)
      Dir[File.join desk, course, '*', '_roster.csv'].map! do |fn|
        File.basename File.dirname fn
      end
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
