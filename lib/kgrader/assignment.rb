module KGrader
  class Assignment
    attr_reader :name, :manifest

    def initialize(filesystem, course, name)
      @fs = filesystem
      @course = course
      @name = name

      @root = @fs.assignment @course.name, @name
      @config = @fs.load @fs.assignment_config(@course.name, @name)
      @manifest = build_manifest
    rescue FilesystemError
      raise AssignmentError, "unknown assignment: #{name}"
    end

    def id
      @config['id'] || @name
    end

    def build_manifest
      unless @config.include? 'manifest'
        raise AssignmentError, "missing manifest: #{@name}"
      end

      manifest = @config['manifest']
      provided = manifest['provided'].map do |fn|
        { :name => fn, :path => File.join(@root, 'provided', fn) }
      end
      graded = manifest['graded'].map { |fn| { :name => fn } }

      {
        :provided => provided,
        :graded => graded,
        :report => manifest['report']
      }
    end
  end
end
