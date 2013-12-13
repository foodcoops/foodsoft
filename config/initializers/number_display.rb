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
    def to_s
      foodsoft_to_s.chomp(".0")
    end
  end
end
