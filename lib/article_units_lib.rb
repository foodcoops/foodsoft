class ArticleUnitsLib
  DEFAULT_PIECE_UNIT_CODES = %w[PTN STC XCU XCN XSH X43 XST XOK XVA XBX XBH XBE XCX XBJ XUN XOS XDH XBA XFI XBO XBQ XFB XFT XJR XGR XOW X8B XCV XWA XEI XJT XGY XJY XBD XCR XAI XPA XBK XBI XOV XNT XPK XPC XPX X5M XPR XEC X6H X44 XBR XCW XBT XSA XBM XSX XDN XAE XSC XLU X5L XPP XPU XBG XP2 XCK XPT XGI XTU]
  DEFAULT_METRIC_SCALAR_UNIT_CODES = %w[KGM HGM DJ GRM LTR DLT CLT MLT]
  DEFAULT_IMPERIAL_SCALAR_UNIT_CODES = %w[LBR ONZ GLL QTI PTI]

  @un_ece_20_units = YAML.safe_load(ERB.new(File.read(File.expand_path(
                                                        'config/units-of-measure/un-ece-20-remastered.yml', Rails.root
                                                      ))).result)
  @un_ece_21_units = YAML.safe_load(ERB.new(File.read(File.expand_path('config/units-of-measure/un-ece-21.yml',
                                                                       Rails.root))).result)

  def self.untranslated_units
    return @untranslated_units unless @untranslated_units.nil?

    options = {}

    @un_ece_20_units.each do |unit|
      code = unit['CommonCode']
      base_unit = unit['conversion']['base_units'].nil? ? nil : unit['conversion']['base_units'][0]
      options[code] =
        { name: unit['Name'], description: unit['Description'], baseUnit: base_unit,
          conversionFactor: unit['conversion']['factor'], symbol: unit['Symbol'] }
    end

    @un_ece_21_units.each do |unit|
      code = 'X' + unit['Code']
      name = unit['Name']
      name[0] = name[0].downcase

      options[code] =
        { name: name, description: unit['Description'], baseUnit: nil, conversionFactor: nil, symbol: unit['Symbol'] }
    end

    options.each do |code, option|
      option[:translation_available] = !ArticleUnitsLib.get_translated_name_for_code(code, default_nil: true).nil?
    end

    @untranslated_units = options
  end

  def self.unit_translations
    @unit_translations = {} if @unit_translations.nil?
    unit_translations_cached_in_current_locale = @unit_translations[I18n.locale]
    return unit_translations_cached_in_current_locale unless unit_translations_cached_in_current_locale.nil?

    @unit_translations[I18n.locale] = YAML.safe_load(ERB.new(File.read(File.expand_path(
                                                                         "config/units-of-measure/locales/unece_#{I18n.locale}.yml", Rails.root
                                                                       ))).result) || {}
  end

  def self.units
    @units = {} if @units.nil?
    units_cached_in_current_locale = @units[I18n.locale]
    return units_cached_in_current_locale unless units_cached_in_current_locale.nil?

    @units[I18n.locale] = untranslated_units.to_h do |code, untranslated_unit|
      translated_name = ArticleUnitsLib.get_translated_name_for_code(code, default_nil: true)
      unit = untranslated_unit.clone
      unit[:name] = translated_name || unit[:name]
      unit[:untranslated] = translated_name.nil?
      unit[:symbol] = ArticleUnitsLib.get_translated_symbol_for_code(code)
      unit[:aliases] = ArticleUnitsLib.get_translated_aliases_for_code(code)

      [code, unit]
    end
  end

  def self.unit_is_si_convertible(code)
    !units[code]&.dig(:conversionFactor).nil?
  end

  def self.human_readable_unit(unit_code)
    unit = units.to_h[unit_code]
    unit[:symbol] || unit[:name]
  end

  def self.get_translated_name_for_code(code, default_nil: false)
    return nil if code.blank?

    unit_translations&.dig('unece_units')&.dig(code)&.dig('name') || (default_nil ? nil : untranslated_units[code][:name])
  end

  def self.get_translated_symbol_for_code(code)
    return nil if code.blank?

    unit_translations&.dig('unece_units')&.dig(code)&.dig('symbols')&.dig(0) || untranslated_units[code][:symbol]
  end

  def self.get_translated_aliases_for_code(code)
    return nil if code.blank?

    unit_translations&.dig('unece_units')&.dig(code)&.dig('aliases')
  end

  def self.get_code_for_unit_name(name)
    return nil if name.blank?

    translation = unit_translations&.dig('unece_units')&.find do |_code, translations|
      translations['name'] == name
    end

    return translation[0] unless translation.nil?

    matching_unit = units.find do |_code, unit|
      unit[:name] == name
    end

    matching_unit[0]
  end

  def self.convert_old_unit(old_compound_unit_str, unit_quantity)
    return nil if old_compound_unit_str.nil?

    md = old_compound_unit_str.match(/([0-9]*)x(.*)/)
    old_compound_unit_str = md[2] if !md.nil? && md[1].to_f == unit_quantity

    md = old_compound_unit_str.match(%r{^\s*([0-9][0-9,./]*)?\s*([A-Za-z\u00C0-\u017F.]+)\s*$})
    return nil if md.nil?

    unit = get_unit_from_old_str(md[2])
    return nil if unit.nil?

    quantity = get_quantity_from_old_str(md[1])

    if quantity == 1 && unit_quantity == 1
      {
        supplier_order_unit: unit,
        first_ratio: nil,
        group_order_granularity: 1.0,
        group_order_unit: unit
      }
    else
      supplier_order_unit = unit.starts_with?('X') && unit != 'XPK' ? 'XPK' : 'XPP'
      {
        supplier_order_unit: supplier_order_unit,
        first_ratio: {
          quantity: quantity * unit_quantity,
          unit: unit
        },
        group_order_granularity: unit_quantity > 1 ? quantity : 1.0,
        group_order_unit: unit_quantity > 1 ? unit : supplier_order_unit
      }
    end
  end

  def self.get_quantity_from_old_str(quantity_str)
    return 1 if quantity_str.nil?

    quantity_str = quantity_str
                   .gsub(',', '.')
                   .gsub(' ', '')

    division_parts = quantity_str.split('/').map(&:to_f)

    if division_parts.length == 2
      division_parts[0] / division_parts[1]
    else
      quantity_str.to_f
    end
  end

  def self.get_unit_from_old_str(old_unit_str)
    unit_str = old_unit_str.strip.downcase
    units = ArticleUnitsLib.untranslated_units
                           .sort { |a, b| sort_by_translation_state(a[1], b[1]) }
    matching_unit_arr = units.select { |key, unit| matches_unit(key, unit, unit_str) }
                             .to_a
    return nil if matching_unit_arr.empty?

    matching_unit_arr[0][0]
  end

  def self.sort_by_translation_state(unit_a, unit_b)
    return -1 if unit_a[:translation_available] && !unit_b[:translation_available]
    return 1 if unit_b[:translation_available] && !unit_a[:translation_available]

    0
  end

  def self.matches_unit(unit_code, unit, unit_str)
    return true if unit[:symbol] == unit_str

    translation_data = unit_translations&.dig('unece_units')&.dig(unit_code)

    return true if translation_data&.dig('symbols')&.include?(unit_str)

    name = translation_data&.dig('name')&.downcase
    return true if !name.nil? && name == unit_str

    aliases = translation_data&.dig('aliases')&.map(&:strip)&.map(&:downcase)
    !aliases.nil? && aliases.any? { |a| a == unit_str || "#{a}." == unit_str }
  end
end
