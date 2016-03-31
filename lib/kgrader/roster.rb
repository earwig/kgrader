module KGrader
  class Roster
    attr_reader :semester

    def initialize(filesystem, course, semester)
      @fs = filesystem
      @course = course
      @semester = semester
      @students = nil
    end

    def load(filename)
      @students = @fs.load(filename).map! { |item| item.first }
      FileUtils.mkdir_p File.dirname(rosterfile)
      File.write rosterfile, @students.join("\n")
    rescue FilesystemError => err
      raise RosterError, err
    end

    def students
      @students ||= @fs.load(rosterfile).map! { |item| item.first }
    rescue FilesystemError
      raise RosterError, "unknown semester: #{semester}"
    end

    private
    def rosterfile
      @fs.roster @course.name, @semester
    end
  end
end
