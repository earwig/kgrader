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

  class AssignmentError < KGraderError
  end

  class TaskError < KGraderError
  end

  class SubmissionError < KGraderError
  end
end
