require 'date'

module KGrader
  def self.parse_args(raw, num, keywords)
    args = []
    options = {}

    raw.each do |arg|
      if arg.include? '='
        key, val = arg.split('=', 2)
        key = key.to_sym
        yield "unknown keyword #{key}" unless keywords.include? key
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

    yield "too few arguments" if args.size < num
    yield "too many arguments" if args.size > num
    return args, options
  end
end
