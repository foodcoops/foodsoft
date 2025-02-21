class Article < ApplicationRecord
  include LocalizeInput
  include PriceCalculation

  # @!attribute name
  #   @return [String] Article name
  # @!attribute unit
  #   @return [String] Unit, e.g. +kg+, +2 L+ or +5 pieces+.
  # @!attribute note
  #   @return [String] Short line with optional extra article information.
  # @!attribute availability
  #   @return [Boolean] Whether this article is available within the Foodcoop.
  # @!attribute manufacturer
  #   @return [String] Original manufacturer.
  # @!attribute origin
  #   Where the article was produced.
  #   ISO 3166-1 2-letter country code, optionally prefixed with region.
  #   E.g. +NL+ or +Sicily, IT+ or +Berlin, DE+.
  #   @return [String] Production origin.
  #   @see http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements
  # @!attribute price
  #   @return [Number] Net price
  #   @see ArticleVersion#price
  # @!attribute tax
  #   @return [Number] VAT percentage (10 is 10%).
  #   @see ArticleVersion#tax
  # @!attribute deposit
  #   @return [Number] Deposit
  #   @see ArticleVersion#deposit
  # @!attribute unit_quantity
  #   @return [Number] Number of units in wholesale package (box).
  #   @see ArticleVersion#unit_quantity
  # @!attribute order_number
  # Order number, this can be used by the supplier to identify articles.
  # This is required when using the shared database functionality.
  #   @return [String] Order number.
  # @!attribute article_category
  #   @return [ArticleCategory] Category this article is in.
  # @!attribute supplier
  #   @return [Supplier] Supplier this article belongs to.
  belongs_to :supplier
  # @!attribute article_versions
  #   @return [Array<ArticleVersion>] Price history (current price first).
  has_many :article_versions, -> { order('created_at DESC') }

  # @!attribute order
  #   @return [Array<Order>] Orders this article appears in.
  has_many :orders, through: :order_articles

  has_one :latest_article_version, lambda {
                                     merge(ArticleVersion.latest)
                                   }, foreign_key: :article_id, class_name: :ArticleVersion

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :available, -> { undeleted.with_latest_versions_and_categories.where(article_versions: { availability: true }) }
  scope :not_in_stock, -> { where(type: nil) }

  scope :with_latest_versions_and_categories, lambda {
    includes(:latest_article_version)
      .joins(article_versions: [:article_category])
      .joins(ArticleVersion.latest_outer_join_sql("#{table_name}.#{primary_key}"))
      .where(later_article_versions: { id: nil })
  }

  scope :with_latest_versions, lambda {
    includes(:latest_article_version)
      .joins(:article_versions)
      .joins(ArticleVersion.latest_outer_join_sql("#{table_name}.#{primary_key}"))
      .where(later_article_versions: { id: nil })
  }

  accepts_nested_attributes_for :latest_article_version

  # TODO: Remove these (see https://github.com/foodcoopsat/foodsoft_hackathon/issues/91):
  begin
    ArticleVersion.column_names.each do |column_name|
      next if column_name == ArticleVersion.primary_key
      next if column_name == 'article_id'

      delegate column_name, "#{column_name}=", to: :latest_article_version, allow_nil: true
    end
  rescue StandardError
    # Ignore if these delegates cannot be created (can happen if table article_versions doesn't yet exist in migrations)
  end

  delegate :article_category, to: :latest_article_version, allow_nil: true
  delegate :article_unit_ratios, to: :latest_article_version, allow_nil: true

  # Callbacks
  before_save :update_or_create_article_version
  before_destroy :check_article_in_use
  after_save :reload_article_on_version_change

  def self.ransackable_attributes(_auth_object = nil)
    # TODO: - see https://github.com/foodcoopsat/foodsoft_hackathon/issues/92
    %w[id name supplier_id article_category_id unit note manufacturer origin unit_quantity order_number]
  end

  def self.ransackable_associations(_auth_object = nil)
    # TODO: - see https://github.com/foodcoopsat/foodsoft_hackathon/issues/92
    %w[article_category supplier order_articles orders]
  end

  # Returns true if article has been updated at least 2 days ago
  def recently_updated
    latest_article_version.updated_at > 2.days.ago
  end

  # If the article is used in an open Order, the Order will be returned.
  def in_open_order
    @in_open_order ||= begin
      order_articles = OrderArticle.where(order_id: Order.open.collect(&:id))
      order_article = order_articles.detect { |oa| oa.article_version.article_id == id }
      order_article ? order_article.order : nil
    end
  end

  # Returns true if the article has been ordered in the given order at least once
  def ordered_in_order?(order)
    order.order_articles.includes(:article_version).where(article_version: { article_id: id }).where('quantity > 0').one?
  end

  # to get the correspondent shared article
  def shared_article(supplier = self.supplier)
    order_number.blank? and return nil
    @shared_article ||= begin
                          supplier.shared_supplier.find_article_by_number(order_number)
    rescue StandardError
                          nil
    end
  end

  # Return article attributes that were changed (incl. unit conversion)
  # @param new_article [Article] New article to update self
  # @option options [Boolean] :convert_units Omit or set to +true+ to keep current unit and recompute unit quantity and price.
  # @return [Hash<Symbol, Object>] Attributes with new values
  def unequal_attributes(new_article, options = {})
    # try to convert different units when desired
    if options[:convert_units] == false
      new_price = nil
      new_unit_quantity = nil
    else
      new_price, new_unit_quantity = convert_units(new_article)
    end
    if new_price && new_unit_quantity
      new_unit = unit
    else
      new_price = new_article.price
      new_unit_quantity = new_article.unit_quantity
      new_unit = new_article.unit
    end

    ret = ArticleVersion.compare_attributes(
      {
        name: [latest_article_version.name, new_article.name],
        manufacturer: [latest_article_version.manufacturer, new_article.manufacturer.to_s],
        origin: [latest_article_version.origin, new_article.origin],
        unit: [latest_article_version.unit, new_unit],
        supplier_order_unit: [latest_article_version.supplier_order_unit, new_article.supplier_order_unit],
        minimum_order_quantity: [latest_article_version.minimum_order_quantity, new_article.minimum_order_quantity],
        billing_unit: [latest_article_version.billing_unit || latest_article_version.supplier_order_unit,
                       new_article.billing_unit || new_article.supplier_order_unit],
        group_order_granularity: [latest_article_version.group_order_granularity, new_article.group_order_granularity],
        group_order_unit: [latest_article_version.group_order_unit, new_article.group_order_unit],
        price: [latest_article_version.price.to_f.round(2), new_price.to_f.round(2)],
        tax: [latest_article_version.tax, new_article.tax],
        deposit: [latest_article_version.deposit.to_f.round(2), new_article.deposit.to_f.round(2)],
        note: [latest_article_version.note.to_s, new_article.note.to_s]
      }
    )

    ratios_differ = latest_article_version.article_unit_ratios.length != new_article.article_unit_ratios.length ||
                    latest_article_version.article_unit_ratios.each_with_index.any? do |article_unit_ratio, index|
                      new_article.article_unit_ratios[index].unit != article_unit_ratio.unit ||
                        new_article.article_unit_ratios[index].quantity != article_unit_ratio.quantity
                    end

    if ratios_differ
      ratio_attribs = new_article.article_unit_ratios.map(&:attributes)
      ret[:article_unit_ratios_attributes] = ratio_attribs
    end

    if options[:convert_units] && latest_article_version.article_unit_ratios.length < 2 && new_article.article_unit_ratios.length < 2 && !new_unit_quantity.nil?
      ret[:article_unit_ratios_attributes] = [new_article.article_unit_ratios.build(unit: 'XPP', quantity: new_unit_quantity, sort: 1).attributes]
      # TODO: Either remove this aspect of the :convert_units feature or extend it to also work for the new units system (see https://github.com/foodcoopsat/foodsoft_hackathon/issues/90)
    end

    ret
  end

  # convert units in foodcoop-size
  # uses unit factors in app_config.yml to calc the price/unit_quantity
  # returns new price and unit_quantity in array, when calc is possible => [price, unit_quantity]
  # returns false if units aren't foodsoft-compatible
  # returns nil if units are eqal
  def convert_units(new_article = shared_article)
    return unless unit != new_article.unit

    return false if new_article.unit.include?(',')

    # legacy, used by foodcoops in Germany
    if new_article.unit == 'KI' && unit == 'ST' # 'KI' means a box, with a different amount of items in it
      # try to match the size out of its name, e.g. "banana 10-12 St" => 10
      new_unit_quantity = /[0-9\-\s]+(St)/.match(new_article.name).to_s.to_i
      if new_unit_quantity && new_unit_quantity > 0
        new_price = (new_article.price / new_unit_quantity.to_f).round(2)
        [new_price, new_unit_quantity]
      else
        false
      end
    else # use ruby-units to convert
      fc_unit = begin
        ::Unit.new(unit)
      rescue StandardError
        nil
      end
      supplier_unit = begin
        ::Unit.new(new_article.unit)
      rescue StandardError
        nil
      end
      if fc_unit != 0 && supplier_unit != 0 && fc_unit && supplier_unit && fc_unit =~ supplier_unit
        conversion_factor = (supplier_unit / fc_unit).to_base.to_r
        new_price = new_article.price / conversion_factor
        new_unit_quantity = new_article.unit_quantity * conversion_factor
        [new_price, new_unit_quantity]
      else
        false
      end
    end
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    check_article_in_use
    update_column :deleted_at, Time.now
  end

  def current_article_units
    [supplier_order_unit, group_order_unit, billing_unit, price_unit, article_unit_ratios.map(&:unit)]
      .flatten
      .uniq
      .compact
  end

  def duplicate_including_latest_version_and_ratios
    article = dup
    article.latest_article_version = latest_article_version.duplicate_including_article_unit_ratios
    article
  end

  protected

  # Checks if the article is in use before it will deleted
  def check_article_in_use
    raise I18n.t('articles.model.error_in_use', article: name.to_s) if in_open_order
  end

  # Create an ArticleVersion, when the price-attr are changed.
  def update_or_create_article_version
    @version_changed_before_save = false
    return unless version_dup_required?

    old_version = latest_article_version
    new_version = old_version.duplicate_including_article_unit_ratios
    article_versions << new_version

    OrderArticle.belonging_to_open_order
                .joins(:article_version)
                .where(article_versions: { article_id: id })
                .update_all(article_version_id: new_version.id)

    # reload old version to avoid updating it too (would automatically happen after before_save):
    old_version.reload

    @version_changed_before_save = true
  end

  def reload_article_on_version_change
    reload if @version_changed_before_save
    @version_changed_before_save = false
  end

  def version_dup_required?
    return false if latest_article_version.nil?
    return false unless latest_article_version.self_or_ratios_changed?

    OrderArticle.belonging_to_finished_order.exists?(article_version_id: latest_article_version.id)
  end
end
