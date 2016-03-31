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

    # -------------------------------------------------------------------------

    def course(name)
      File.join spec, name
    end

    def course_config(name)
      File.join course(name), '_config.yml'
    end

    def assignment(courseid, name)
      File.join course(courseid), name, '_config.yml'
    end

    def roster(courseid, semester)
      File.join desk, courseid, semester, '_roster.csv'
    end

    # -------------------------------------------------------------------------

    def courses
      Dir[File.join spec, '*', ''].map! { |fn| File.basename fn }
    end

    def assignments(courseid)
      Dir[assignment courseid '*'].map! { |fn| File.basename File.dirname fn }
    end

    def semesters(courseid)
      Dir[roster courseid, '*'].map! { |fn| File.basename File.dirname fn }
    end

    # -------------------------------------------------------------------------

    def load(path)
      case File.extname path
      when '.yml', '.yaml'
        YAML.load File.read(path)
      when '.csv'
        File.read(path).split("\n").map! { |line| line.split "," }
      else
        raise FilesystemError, "unknown file type: #{path}"
      end
    rescue SystemCallError  # Errno::ENOENT, etc.
      raise FilesystemError, "can't read file: #{path}"
    end
  end
end
