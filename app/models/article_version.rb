class ArticleVersion < ApplicationRecord
  include LocalizeInput
  include PriceCalculation

  # @!attribute price
  #   @return [Number] Net price
  #   @see Article#price
  # @!attribute tax
  #   @return [Number] VAT percentage
  #   @see Article#tax
  # @!attribute deposit
  #   @return [Number] Deposit
  #   @see Article#deposit
  # @!attribute unit_quantity
  #   @return [Number] Number of units in wholesale package (box).
  #   @see Article#unit
  #   @see Article#unit_quantity
  # @!attribute article
  #   @return [Article] Article this price is about.
  belongs_to :article
  belongs_to :article_category
  # @!attribute order_articles
  #   @return [Array<OrderArticle>] Order articles this price is associated with.
  has_many :order_articles

  has_many :article_unit_ratios, after_add: :on_article_unit_ratios_change,
                                 after_remove: :on_article_unit_ratios_change, dependent: :destroy

  localize_input_of :price, :tax, :deposit

  # Validations
  validates :name, :price, :tax, :deposit, :article_category, presence: true
  validates :name, length: { in: 4..60 }
  validates :unit, length: { in: 1..15, unless: :supplier_order_unit }
  validates :supplier_order_unit, presence: { unless: :unit }
  validates :note, length: { maximum: 255 }
  validates :origin, length: { maximum: 255 }
  validates :manufacturer, length: { maximum: 255 }
  validates :order_number, length: { maximum: 255 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :group_order_granularity, numericality: { greater_than_or_equal_to: 0 }
  validates :deposit, :tax, numericality: true
  validates :minimum_order_quantity, numericality: { allow_nil: true }

  # validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type], if: Proc.new {|a| a.supplier.shared_sync_method.blank? or a.supplier.shared_sync_method == 'import' }
  # validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type, :unit, :unit_quantity]
  validate :uniqueness_of_name
  validate :only_one_unit_type
  validate :minimum_order_quantity_as_integer, unless: :supplier_order_unit_is_si_convertible

  # Replace numeric seperator with database format
  localize_input_of :price, :tax, :deposit
  # Get rid of unwanted whitespace. {Unit#new} may even bork on whitespace.
  normalize_attributes :name, :unit, :note, :manufacturer, :origin, :order_number

  accepts_nested_attributes_for :article_unit_ratios, allow_destroy: true

  scope :latest, lambda {
    joins(latest_outer_join_sql("#{table_name}.article_id")).where(later_article_versions: { id: nil })
  }

  def self.latest_outer_join_sql(article_field_name)
    %(
      LEFT OUTER JOIN #{table_name} later_article_versions
      ON later_article_versions.article_id = #{article_field_name}
        AND later_article_versions.created_at > #{table_name}.created_at
    )
  end

  def supplier_order_unit_is_si_convertible
    ArticleUnitsLib.unit_is_si_convertible(supplier_order_unit)
  end

  # TODO: Maybe use the `nilify_blanks` gem instead of the following six methods? (see https://github.com/foodcoopsat/foodsoft_hackathon/issues/93):
  def unit=(value)
    if value.blank?
      self[:unit] = nil
    else
      super
    end
  end

  def supplier_order_unit=(value)
    if value.blank?
      self[:supplier_order_unit] = nil
    else
      super
    end
  end

  def group_order_unit=(value)
    if value.blank?
      self[:group_order_unit] = nil
    else
      super
    end
  end

  def price_unit=(value)
    if value.blank?
      self[:price_unit] = nil
    else
      super
    end
  end

  def billing_unit=(value)
    if value.blank?
      self[:billing_unit] = nil
    else
      super
    end
  end

  def minimum_order_quantity=(value)
    if value.blank?
      self[:minimum_order_quantity] = nil
    else
      super
    end
  end

  def self_or_ratios_changed?
    changed? || @article_unit_ratios_changed || article_unit_ratios.any?(&:changed?)
  end

  def duplicate_including_article_unit_ratios
    new_version = dup
    article_unit_ratios.each do |ratio|
      ratio = ratio.dup
      ratio.article_version_id = nil
      new_version.article_unit_ratios << ratio
    end

    new_version
  end

  # Compare attributes from two different articles.
  #
  # This is used for auto-synchronization
  # @param attributes [Hash<Symbol, Array>] Attributes with old and new values
  # @return [Hash<Symbol, Object>] Changed attributes with new values
  def self.compare_attributes(attributes)
    unequal_attributes = attributes.select do |_name, values|
      values[0] != values[1] && !(values[0].blank? && values[1].blank?)
    end
    unequal_attributes.to_a.map { |a| [a[0], a[1].last] }.to_h
  end

  def uses_tolerance?
    (
      !supplier_order_unit_is_si_convertible &&
      convert_quantity(1, supplier_order_unit, group_order_unit) != group_order_granularity
    ) || (minimum_order_quantity.presence || 0) > group_order_granularity
  end

  protected

  # We used have the name unique per supplier+deleted_at+type. With the addition of shared_sync_method all,
  # this came in the way, and we now allow duplicate names for the 'all' methods - expecting foodcoops to
  # make their own choice among products with different units by making articles available/unavailable.
  def uniqueness_of_name
    matches = Article.with_latest_versions.where(article_versions: { name: name },
                                                 supplier_id: article.supplier_id,
                                                 deleted_at: article.deleted_at,
                                                 type: article.type)
    matches = matches.where.not(id: article.id) unless article.new_record?
    # supplier should always be there - except, perhaps, on initialization (on seeding)
    if article.supplier && (article.supplier.shared_sync_method.blank? || article.supplier.shared_sync_method == 'import')
      errors.add :name, :taken if matches.any?
    else
      article_unit_ratios.each_with_index do |article_unit_ratio, index|
        matches = matches.joins(%(
          INNER JOIN #{ArticleUnitRatio.table_name} #{ArticleUnitRatio.table_name}_#{index}
          ON #{ArticleUnitRatio.table_name}_#{index}.article_version_id = #{ArticleVersion.table_name}.id
            AND #{ArticleUnitRatio.table_name}_#{index}.sort = #{ArticleUnitRatio.connection.quote(article_unit_ratio.sort)}
            AND #{ArticleUnitRatio.table_name}_#{index}.unit = #{ArticleUnitRatio.connection.quote(article_unit_ratio.unit)}
            AND #{ArticleUnitRatio.table_name}_#{index}.quantity = #{ArticleUnitRatio.connection.quote(article_unit_ratio.quantity)}
        ))
      end

      errors.add :name, :taken_with_unit if matches.where(article_versions: { supplier_order_unit: supplier_order_unit, unit: unit }).any?
    end
  end

  def minimum_order_quantity_as_integer
    begin
      return if Float(minimum_order_quantity) % 1 == 0
    rescue ArgumentError, TypeError
      # not any number -> let numericality validation handle this
      return
    end

    errors.add(:minimum_order_quantity, :only_integer)
  end

  def only_one_unit_type
    return if unit.blank? || supplier_order_unit.blank?

    errors.add :unit # not specifying a specific error message as this should be prevented by js
  end

  def on_article_unit_ratios_change(_some_change)
    @article_unit_ratios_changed = true
  end
end
