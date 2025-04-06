module ArticlesHelper
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    return unless unequal_attributes

    intersection = (unequal_attributes.keys & attributes)
    intersection.empty? ? '' : 'background-color: yellow'
  end

  def row_classes(article)
    classes = []
    classes << 'unavailable' unless article.availability
    classes << 'just-updated' if article.recently_updated && article.availability
    classes.join(' ')
  end

  def format_supplier_order_unit(article)
    format_unit(:supplier_order_unit, article)
  end

  def format_group_order_unit(article)
    format_unit(:group_order_unit, article)
  end

  def format_billing_unit(article)
    format_unit(:billing_unit, article)
  end

  def format_price_unit(article)
    format_unit(:price_unit, article)
  end

  def format_supplier_order_unit_with_ratios(article)
    format_unit_with_ratios(:supplier_order_unit, article)
  end

  def format_group_order_unit_with_ratios(article)
    format_unit_with_ratios(:group_order_unit, article)
  end

  def format_billing_unit_with_ratios(article)
    format_unit_with_ratios(:billing_unit, article)
  end

  def field_with_preset_value_and_errors(options)
    form, field, value, field_errors, input_html = options.values_at(:form, :field, :value, :errors, :input_html)
    form.input field, label: false, wrapper_html: { class: field_errors.blank? ? '' : 'error' },
                      input_html: input_html do
      output = [form.input_field(field, { value: value }.merge(input_html))]
      if field_errors.present?
        errors = tag.span(class: 'help-inline') do
          field_errors.join(', ')
        end
        output << errors
      end
      safe_join(output)
    end
  end

  private

  def format_unit_with_ratios(unit_property, article_version, reference_unit = :group_order_unit)
    base = format_unit(unit_property, article_version)

    factorized_unit_str = get_factorized_unit_str(article_version, unit_property, reference_unit) unless reference_unit.nil?
    return base if factorized_unit_str.nil?

    "#{base} (#{factorized_unit_str})"
  end

  def format_unit(unit_property, article)
    unit_code = article.send(unit_property)
    return article.unit if unit_code.nil?

    ArticleUnitsLib.human_readable_unit(unit_code)
  end

  def get_factorized_unit_str(article_version, unit_property, reference_unit)
    unit_code = article_version.send(unit_property)
    reference_unit_code = article_version.send(reference_unit) || article_version.supplier_order_unit
    return nil if ArticleUnitsLib.unit_is_si_convertible(unit_code)

    factors = [{
      quantity: article_version.convert_quantity(1, unit_code, reference_unit_code),
      code: reference_unit_code
    }]

    first_si_conversible_unit_after_reference_unit = get_first_si_conversible_unit(article_version, reference_unit_code) unless ArticleUnitsLib.unit_is_si_convertible(reference_unit_code)
    unless first_si_conversible_unit_after_reference_unit.nil?
      factors << {
        quantity: article_version.convert_quantity(1, reference_unit_code, first_si_conversible_unit_after_reference_unit),
        code: first_si_conversible_unit_after_reference_unit
      }
    end

    return nil if factors.length == 1 && factors.first[:quantity] == 1 && factors.first[:code] == unit_code

    format_unit_factors(factors)
  end

  def get_first_si_conversible_unit(article_version, after_unit)
    relevant_units = [article_version.supplier_order_unit] + article_version.article_unit_ratios.map(&:unit)

    unit_index = relevant_units.find_index { |unit| unit == after_unit }
    return nil if unit_index.nil?

    relevant_units[unit_index + 1..].find { |unit| ArticleUnitsLib.unit_is_si_convertible(unit) }
  end

  def format_unit_factors(factors)
    factor_str_arr = factors.each_with_index.map do |factor, index|
      is_last = index + 1 == factors.length
      format_unit_factor(factor, is_last)
    end

    factor_str_arr
      .compact
      .join("#{Prawn::Text::NBSP}×#{Prawn::Text::NBSP}")
  end

  def format_unit_factor(factor, with_unit)
    return nil if !with_unit && factor[:quantity] == 1

    quantity_str = number_with_precision(factor[:quantity], precision: 2, strip_insignificant_zeros: true)
    return quantity_str unless with_unit

    unit_data = ArticleUnitsLib.units.to_h[factor[:code]]
    is_si_conversible = ArticleUnitsLib.unit_is_si_convertible(factor[:code])
    unit_label = is_si_conversible ? unit_data[:symbol] : unit_data[:name]
    return unit_label if factor[:quantity] == 1

    multiplier_str = '×' unless is_si_conversible

    [quantity_str, multiplier_str, unit_label]
      .compact
      .join(Prawn::Text::NBSP)
  end
end
