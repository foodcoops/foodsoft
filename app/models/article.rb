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
  #   @see ArticlePrice#price
  # @!attribute tax
  #   @return [Number] VAT percentage (10 is 10%).
  #   @see ArticlePrice#tax
  # @!attribute deposit
  #   @return [Number] Deposit
  #   @see ArticlePrice#deposit
  # @!attribute unit_quantity
  #   @return [Number] Number of units in wholesale package (box).
  #   @see ArticlePrice#unit_quantity
  # @!attribute order_number
  # Order number, this can be used by the supplier to identify articles.
  # This is required when using the shared database functionality.
  #   @return [String] Order number.
  # @!attribute article_category
  #   @return [ArticleCategory] Category this article is in.
  belongs_to :article_category
  # @!attribute supplier
  #   @return [Supplier] Supplier this article belongs to.
  belongs_to :supplier
  # @!attribute article_prices
  #   @return [Array<ArticlePrice>] Price history (current price first).
  has_many :article_prices, -> { order('created_at DESC') }
  # @!attribute order_articles
  #   @return [Array<OrderArticle>] Order articles for this article.
  has_many :order_articles
  # @!attribute order
  #   @return [Array<Order>] Orders this article appears in.
  has_many :orders, through: :order_articles

  # Replace numeric seperator with database format
  localize_input_of :price, :tax, :deposit
  # Get rid of unwanted whitespace. {Unit#new} may even bork on whitespace.
  normalize_attributes :name, :unit, :note, :manufacturer, :origin, :order_number

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :available, -> { undeleted.where(availability: true) }
  scope :not_in_stock, -> { where(type: nil) }

  # Validations
  validates :name, :unit, :price, :tax, :deposit, :unit_quantity, :supplier_id, :article_category, presence: true
  validates :name, length: { in: 4..60 }
  validates :unit, length: { in: 1..15 }
  validates :note, length: { maximum: 255 }
  validates :origin, length: { maximum: 255 }
  validates :manufacturer, length: { maximum: 255 }
  validates :order_number, length: { maximum: 255 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_quantity, numericality: { greater_than: 0 }
  validates :deposit, :tax, numericality: true
  # validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type], if: Proc.new {|a| a.supplier.shared_sync_method.blank? or a.supplier.shared_sync_method == 'import' }
  # validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type, :unit, :unit_quantity]
  validate :uniqueness_of_name

  # Callbacks
  before_save :update_price_history
  before_destroy :check_article_in_use

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name supplier_id article_category_id unit note manufacturer origin unit_quantity order_number]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[article_category supplier order_articles orders]
  end

  # Returns true if article has been updated at least 2 days ago
  def recently_updated
    updated_at > 2.days.ago
  end

  # If the article is used in an open Order, the Order will be returned.
  def in_open_order
    @in_open_order ||= begin
      order_articles = OrderArticle.where(order_id: Order.open.collect(&:id))
      order_article = order_articles.detect { |oa| oa.article_id == id }
      order_article&.order
    end
  end

  # Returns true if the article has been ordered in the given order at least once
  def ordered_in_order?(order)
    order.order_articles.where(article_id: id).where('quantity > 0').one?
  end

  # this method checks, if the shared_article has been changed
  # unequal attributes will returned in array
  # if only the timestamps differ and the attributes are equal,
  # false will returned and self.shared_updated_on will be updated
  def shared_article_changed?(supplier = self.supplier)
    # skip early if the timestamp hasn't changed
    shared_article = self.shared_article(supplier)
    return if shared_article.nil? || shared_updated_on == shared_article.updated_on

    attrs = unequal_attributes(shared_article)
    if attrs.empty?
      # when attributes not changed, update timestamp of article
      update_attribute(:shared_updated_on, shared_article.updated_on)
      false
    else
      attrs
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

    Article.compare_attributes(
      {
        name: [name, new_article.name],
        manufacturer: [manufacturer, new_article.manufacturer.to_s],
        origin: [origin, new_article.origin],
        unit: [unit, new_unit],
        price: [price.to_f.round(2), new_price.to_f.round(2)],
        tax: [tax, new_article.tax],
        deposit: [deposit.to_f.round(2), new_article.deposit.to_f.round(2)],
        # take care of different num-objects.
        unit_quantity: [unit_quantity.to_s.to_f, new_unit_quantity.to_s.to_f],
        note: [note.to_s, new_article.note.to_s]
      }
    )
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

  # to get the correspondent shared article
  def shared_article(supplier = self.supplier)
    order_number.blank? and return nil
    @shared_article ||= begin
      supplier.shared_supplier.find_article_by_number(order_number)
    rescue StandardError
      nil
    end
  end

  # convert units in foodcoop-size
  # uses unit factors in app_config.yml to calc the price/unit_quantity
  # returns new price and unit_quantity in array, when calc is possible => [price, unit_quanity]
  # returns false if units aren't foodsoft-compatible
  # returns nil if units are eqal
  def convert_units(new_article = shared_article)
    return unless unit != new_article.unit

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

  protected

  # Checks if the article is in use before it will deleted
  def check_article_in_use
    raise I18n.t('articles.model.error_in_use', article: name.to_s) if in_open_order
  end

  # Create an ArticlePrice, when the price-attr are changed.
  def update_price_history
    return unless price_changed?

    article_prices.build(
      price: price,
      tax: tax,
      deposit: deposit,
      unit_quantity: unit_quantity
    )
  end

  def price_changed?
    changed.detect { |attr| attr == 'price' || 'tax' || 'deposit' || 'unit_quantity' } ? true : false
  end

  # We used have the name unique per supplier+deleted_at+type. With the addition of shared_sync_method all,
  # this came in the way, and we now allow duplicate names for the 'all' methods - expecting foodcoops to
  # make their own choice among products with different units by making articles available/unavailable.
  def uniqueness_of_name
    matches = Article.where(name: name, supplier_id: supplier_id, deleted_at: deleted_at, type: type)
    matches = matches.where.not(id: id) unless new_record?
    # supplier should always be there - except, perhaps, on initialization (on seeding)
    if supplier && (supplier.shared_sync_method.blank? || supplier.shared_sync_method == 'import')
      errors.add :name, :taken if matches.any?
    elsif matches.where(unit: unit, unit_quantity: unit_quantity).any?
      errors.add :name, :taken_with_unit
    end
  end
end
