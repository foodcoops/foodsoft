# we'd like to show "0.0" as "0"

class Float
  alias :foodsoft_to_s :to_s
  def to_s
    foodsoft_to_s.gsub /(\.0*|(\.[0-9]+?)0+)$/, '\2'
  end
end

if defined? BigDecimal
  class BigDecimal
    alias :foodsoft_to_s :to_s
    def to_s(format = DEFAULT_STRING_FORMAT)
      foodsoft_to_s(format).gsub /(\.0*|(\.[0-9]+?)0+)$/, '\2'
    end
  end
end
