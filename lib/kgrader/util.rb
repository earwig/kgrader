require 'time'

module KGrader
  def self.parse_args(raw, range, keywords)
    args = []
    options = {}

    raw.each do |arg|
      if arg.include? '='
        key, val = arg.split('=', 2)
        key = key.to_sym
        unless keywords.include? key
          raise ArgumentError, "unknown keyword: #{key}"
        end
        options[key] = case keywords[key]
        when :string
          val
        when :bool
          %w(true yes 1 t y).include? val.downcase
        when :array
          val.split(",").map! { |x| x.strip.downcase }
        when :time
          Time.parse(val)
        end
      else
        args << arg
      end
    end

    raise ArgumentError, "too few arguments" if args.size < range.begin
    raise ArgumentError, "too many arguments" if args.size > range.end
    args[range.end - 1] = nil unless args.size == range.end
    return args, options
  end

  def self.current_semester(format)
    season = Time.now.strftime('%m').to_i <= 6 ? 'sp' : 'fa'
    case format
    when 'faspYY'
      season + Time.now.strftime('%y')
    when 'faspYYYY'
      season + Time.now.strftime('%Y')
    else
      raise ConfigError, "unknown semester format: #{format}"
    end
  end
end
