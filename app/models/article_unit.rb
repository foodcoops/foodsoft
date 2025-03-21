class ArticleUnit < ApplicationRecord
  self.primary_key = :unit

  before_save { ArticleUnit.clear_cache }
  before_destroy { ArticleUnit.clear_cache }

  def self.all_cached
    @all_cached = {} if @all_cached.nil?
    cached_units_in_locale = @all_cached[I18n.locale]
    return cached_units_in_locale unless cached_units_in_locale.nil?

    @all_cached[I18n.locale] = all.load
  end

  def self.clear_cache
    @all_cached = {}
  end

  def self.as_hash(config = nil)
    additional_units = config&.dig(:additional_units) || []
    available_units = all_cached.map(&:unit)
    ArticleUnitsLib.units.to_h do |code, unit|
      [code, unit.merge({ visible: available_units.include?(code) || additional_units.include?(code) })]
    end
  end

  def self.as_options(config = nil)
    additional_units = config&.dig(:additional_units) || []
    options = {}

    available_units = all_cached.map(&:unit)
    ArticleUnitsLib.units.each do |code, unit|
      next unless available_units.include?(code) || additional_units.include?(code)

      label = unit[:name]
      label += " (#{unit[:symbol]})" if unit[:symbol].present?

      options[label] = code
    end

    options
  end
end
