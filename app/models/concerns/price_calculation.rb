module PriceCalculation
  extend ActiveSupport::Concern

  # Gross price = net price + deposit + tax.
  # @return [Number] Gross price.
  def gross_price
    ((price + deposit) * (tax / 100 + 1)).round(2)
  end

  # @return [Number] Price for the foodcoop-member.
  def fc_price
    (gross_price  * (FoodsoftConfig[:price_markup] / 100 + 1)).round(2)
  end
end
