require 'date'

module KGrader
  def self.die(error)
    Kernel::abort "fatal: #{error}"
  end

  def self.parse_args(raw, num, keywords)
    args = []
    options = {}

    raw.each do |arg|
      if arg.include? '='
        key, val = arg.split('=', 2)
        key = key.to_sym
        die "unknown keyword #{key}" unless keywords.include? key
        options[key] = case keywords[key]
        when :string
          val
        when :bool
          %w(true yes 1 t y).include? val.downcase
        when :array
          val.split(",").map! { |x| x.strip.downcase }
        when :datetime
          DateTime.parse(val)
        end
      else
        args << arg
      end
    end

    die "too few arguments" if args.size < num
    die "too many arguments" if args.size > num
    return args, options
  end

  def self.season
    DateTime.now.strftime('%m').to_i <= 6 ? 'sp' : 'fa'
  end
end
