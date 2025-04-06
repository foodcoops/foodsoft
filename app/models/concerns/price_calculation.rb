module PriceCalculation
  extend ActiveSupport::Concern

  class UnsupportedUnitConversionError < StandardError
    def initialize(msg = 'Unit not supported')
      super
    end
  end

  def unit_quantity
    first_ratio = article_unit_ratios.first
    if first_ratio.nil?
      1
    else
      first_ratio.quantity
    end
  end

  # Gross price = net price + deposit + tax.
  # @return [Number] Gross price.
  def gross_price
    add_percent(price + deposit, tax)
  end

  # @return [Number] Price for the foodcoop-member.
  def fc_price
    add_percent(gross_price, FoodsoftConfig[:price_markup].to_i)
  end

  # get the unit ratio quantity in reference to the supplier_order_unit
  def get_unit_ratio_quantity(unit)
    return 1 if unit == supplier_order_unit

    ratio = new_record? ? article_unit_ratios.detect { |ratio| ratio[:unit] == unit } : find_ratio_by_unit(unit)
    return ratio.quantity unless ratio.nil?

    unit_hash = ArticleUnit.as_hash[unit]
    raise UnsupportedUnitConversionError, "unit '#{unit}' is unknown" if unit_hash.nil?

    related_ratio = article_unit_ratios.detect do |current_ratio|
      ArticleUnit.as_hash[current_ratio.unit][:baseUnit] == unit_hash[:baseUnit]
    end
    return related_ratio.quantity / unit_hash[:conversionFactor] * ArticleUnit.as_hash[related_ratio.unit][:conversionFactor] unless related_ratio.nil?

    supplier_order_unit_conversion_factor = ArticleUnit.as_hash[supplier_order_unit]&.dig(:conversionFactor)
    raise UnsupportedUnitConversionError, "supplier_order_unit '#{supplier_order_unit}' is unknown or has no conversionFactor" if supplier_order_unit_conversion_factor.nil?

    supplier_order_unit_conversion_factor / unit_hash[:conversionFactor]
  end

  def convert_quantity(quantity, input_unit, output_unit)
    quantity / get_unit_ratio_quantity(input_unit) * get_unit_ratio_quantity(output_unit)
  end

  def group_order_price(value = nil)
    value ||= price
    # price is always stored in supplier_order_unit:
    value / convert_quantity(1, supplier_order_unit, group_order_unit)
  end

  def price_unit_price(value = nil)
    value ||= price
    # price is always stored in supplier_order_unit:
    value / convert_quantity(1, supplier_order_unit, price_unit)
  end

  def gross_group_order_price
    group_order_price(gross_price)
  end

  def fc_group_order_price
    group_order_price(fc_price)
  end

  private

  def add_percent(value, percent)
    (value * ((percent * 0.01) + 1)).round(2)
  end

  def find_ratio_by_unit(unit)
    begin
      return article_unit_ratios.detect { |ratio| ratio.unit == unit } if association(:article_unit_ratios).loaded?
    rescue StandardError
      # continue
    end

    article_unit_ratios.find_by_unit(unit)
  end
end
