module PriceCalculation
  extend ActiveSupport::Concern

  # Gross price = net price + deposit + tax.
  # @return [Number] Gross price.
  def gross_price(include_deposit = TRUE)
    if include_deposit
      add_percent(price + deposit, tax)
    else
      add_percent(price, tax)
    end
  end

  # @return [Number] Price for the foodcoop-member.
  def fc_price
    add_percent(gross_price(include_deposit = FALSE), FoodsoftConfig[:price_markup]) + fc_deposit
  end

  def gross_deposit
    add_percent(deposit, tax)
  end

  def fc_deposit
    deposit_with_markup = FALSE # FoodsoftConfig[:deposit_with_markup]
    if deposit_with_markup  
      add_percent(gross_deposit, FoodsoftConfig[:price_markup])
    else
      gross_deposit
    end
  end

  private

  def add_percent(value, percent)
    (value * ((percent * 0.01) + 1)).round(2)
  end
end
