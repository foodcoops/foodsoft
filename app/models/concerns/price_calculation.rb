module PriceCalculation
  extend ActiveSupport::Concern

  # Gross price = net price + deposit + tax.
  # @return [Number] Gross price.
  def gross_price
    add_percent(price + deposit, tax)
  end

  # @return [Number] Price for the foodcoop-member.
  def fc_price
    add_percent(gross_price, FoodsoftConfig[:price_markup])
  end

  def supplier_price
    read_attribute(:supplier_price) || (unit_quantity * price unless unit_quantity.nil? || price.nil?)
  end

  private

  def add_percent(value, percent)
    (value * (percent * 0.01 + 1)).round(2)
  end

end
