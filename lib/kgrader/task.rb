require 'ruby-progressbar'

module KGrader
  class Task

    def initialize(filesystem, course, semester, assignment, students = nil)
      @fs          = filesystem
      @course      = course
      @semester    = semester
      @assignment  = @course.assignment assignment
      @submissions = get_submissions students
    end

    def grade(options = {})
      due = options.fetch(:due, Time.now)
      fetch = options.fetch(:fetch, true)
      regrade = options.fetch(:regrade, false)

      if options.include?(:due) && !fetch
        raise TaskError, "can't set a new due date without fetching"
      end

      subtask 'setup' do |sub|
        sub.create unless sub.exists?
      end

      if fetch
        subtask 'fetch' do |sub|
          sub.fetch due
        end
      end

      subtask 'grade' do |sub|
        if sub.status == :init || sub.status == :fetching
          next 'skip (need to fetch first)'
        elsif sub.status == :graded && !regrade
          next
        else
          sub.grade
        end
      end
    end

    def commit
      subtask 'commit', &:commit
    end

    private
    def get_submissions(students)
      roster = @course.roster(@semester).students
      students.nil? ? (students = roster) : (students &= roster)
      students.map do |student|
        Submission.new @fs, @course, @semester, @assignment, student
      end
    end

    def student_len
      @student_len ||= @submissions.map { |sub| sub.student.length }.max
    end

    def subtask(name)
      progress = ProgressBar.create title: name, total: @submissions.size,
        throttle_rate: 0, format: '%t [%b>%i] %j%% %e    '

      @submissions.each.with_index do |sub, i|
        job = "#{name} [#{sub.student.ljust student_len}]"
        progress.title = "#{job}:"
        result = yield sub
        progress.title = name if i == @submissions.size - 1
        progress.log "#{job}#{': ' if result}#{result}" if result
        progress.increment
      end
    end
  end
end
