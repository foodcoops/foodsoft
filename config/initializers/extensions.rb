# extend the BigDecimal class
class String

  # remove comma from decimal inputs
  def self.delocalized_decimal(string)
    if !string.blank? and string.is_a?(String)
      BigDecimal.new(string.sub(',', '.'))
    else
      string
    end
  end
end