module KGrader
  class Assignment
    attr_reader :name, :manifest

    def initialize(filesystem, course, name)
      @fs = filesystem
      @course = course
      @name = name

      @root = @fs.assignment @course.name, @name
      @config = @fs.load @fs.assignment_config(@course.name, @name)

      verify_config
      @manifest = get_manifest
    rescue FilesystemError
      raise AssignmentError, "unknown assignment: #{name}"
    end

    def id
      @config['id'] || @name
    end

    def title
      @config['title'] || @name
    end

    def build_steps
      @config['build']
    end

    def tests
      @tests ||= @config['grade'].map do |it|
        script = File.join @root, it.keys.first + ".rb"
        { :name => it.keys.first, :script => script, :max => it.values.first }
      end
    end

    def report
      @config['commit']['report'] || "report.txt"
    end

    def commit_message(student)
      default = "Adding grade report for #{title}: {student}"
      template = (@config['commit']['message'] || default).clone
      template['{student}'] = student
      template
    end

    def extra_comments
      @config['commit']['comments'] || []
    end

    private
    def verify_config
      %w(stage build grade).each do |key|
        unless @config.include? key
          raise AssignmentError, "missing #{key} section in config: #{@name}"
        end
      end
    end

    def get_manifest
      stage = @config['stage']
      raise AssignmentError, "chroot is not supported yet" if stage['chroot']

      provided = stage['provided'].map do |fn|
        { :name => fn, :path => File.join(@root, 'provided', fn) }
      end
      graded = stage['graded'].map { |fn| { :name => fn } }

      { :provided => provided, :graded => graded }
    end
  end
end
