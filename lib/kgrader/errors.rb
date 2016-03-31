module KGrader
  class KGraderError < StandardError
  end

  class ArgumentError < KGraderError
  end

  class FilesystemError < KGraderError
  end

  class ConfigError < KGraderError
  end

  class CourseError < KGraderError
  end

  class RosterError < KGraderError
  end
end
