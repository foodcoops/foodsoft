# we'd like to show "0.0" as "0"

class Float
  alias :foodsoft_to_s :to_s
  def to_s
    foodsoft_to_s.chomp(".0")
  end
end

if defined? BigDecimal
  class BigDecimal
    alias :foodsoft_to_s :to_s
    def to_s(format = DEFAULT_STRING_FORMAT)
      foodsoft_to_s(format).chomp(".0")
    end
  end
end
