# we'd like to show "0.0" as "0"

class Float
  alias :foodsoft_to_s :to_s
  def to_s
    foodsoft_to_s.gsub /(\.0*|(\.[0-9]+?)0+)$/, '\2'
  end
end

# allow +to_s+ on bigdecimal without argument too
if defined? BigDecimal
  class BigDecimal
    alias :foodsoft_to_s :to_s
    def to_s(*args)
      if args.present?
        foodsoft_to_s(*args)
      else
        foodsoft_to_s(*args).gsub /(\.0*|(\.[0-9]+?)0+)$/, '\2'
      end
    end
  end
end
