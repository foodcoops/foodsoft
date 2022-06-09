# encoding: utf-8
class Article < ApplicationRecord
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
  has_many :article_prices, -> { order("created_at DESC") }
  # @!attribute supplier_price
  #   @return [Number] Supplier's case price
  #   @see ArticlePrice#supplier_price

  # Replace numeric seperator with database format
  localize_input_of :price, :tax, :deposit
  # Get rid of unwanted whitespace. {Unit#new} may even bork on whitespace.
  normalize_attributes :name, :unit, :note, :manufacturer, :origin, :order_number

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :available, -> { undeleted.where(availability: true) }
  scope :not_in_stock, -> { where(type: nil) }

  # Validations
  validates_presence_of :name, :unit, :price, :tax, :deposit, :unit_quantity, :supplier_id, :article_category
  validates_length_of :name, :in => 4..60
  validates_length_of :unit, :in => 1..15
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_numericality_of :unit_quantity, :greater_than => 0
  validates_numericality_of :deposit, :tax
  #validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type], if: Proc.new {|a| a.supplier.shared_sync_method.blank? or a.supplier.shared_sync_method == 'import' }
  #validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type, :unit, :unit_quantity]
  attr_accessor :skip_validation_uniqueness_of_name
  validate :uniqueness_of_name unless :skip_validation_uniqueness_of_name

  # Callbacks
  before_save :update_price_history, :notify_orders
  before_destroy :check_article_in_use

  # Returns true if article has been updated at least 2 days ago
  def recently_updated
    updated_at > 2.days.ago
  end

  # If the article is used in an open Order, the Order will be returned.
  def in_open_order
    @in_open_order ||= begin
                         order_articles = OrderArticle.where(order_id: Order.open.collect(&:id))
                         order_article = order_articles.detect { |oa| oa.article_id == id }
                         order_article ? order_article.order : nil
                       end
  end

  # If the article is used in an open Order, the Order will be returned.
  def in_open_orders
    @in_open_orders ||= begin
                          order_articles = OrderArticle
                                             .where(order_id: Order.open.collect(&:id))
                                             .where(article_id: id)
                                             .map { |oa| oa.order }
                        end
  end

  def notify_orders
    in_open_orders.each { |o| o.notify_modified }
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
    unless shared_article.nil? || self.shared_updated_on == shared_article.updated_on
      attrs = unequal_attributes(shared_article)
      if attrs.empty?
        # when attributes not changed, update timestamp of article
        # FIXME: i don't think a boolean check should write - also minor performance hit on this
        # self.update_attribute(:shared_updated_on, shared_article.updated_on)
        false
      else
        attrs
      end
    end
  end

  # Return article attributes that were changed (incl. unit conversion)
  # @param new_article [Article] New article to update self
  # @option options [Boolean] :convert_units Omit or set to +true+ to keep current unit and recompute unit quantity and price.
  # @return [Hash<Symbol, Object>] Attributes with new values
  def unequal_attributes(new_article, options = {})
    # try to convert different units when desired
    new_supplier_price = new_article.supplier_price
    if options[:convert_units] == false
      new_price, new_unit_quantity = nil, nil
      # puts "not using convert units"
    else
      new_price, new_unit_quantity = convert_units(new_article)
      # puts "supplier values: #{new_article.price} X #{new_article.unit_quantity} of #{new_article.unit}"
    end
    if new_price && new_unit_quantity
      # puts "converted value: #{new_price} X #{new_unit_quantity} of #{unit}"
      # supplier_amount = Unit.new(new_article.unit.downcase) * new_article.unit_quantity
      # fc_amount = Unit.new(unit.downcase) * new_unit_quantity
      # if (supplier_amount != fc_amount)
      #   raise "sanity check failed #{supplier_amount} != #{fc_amount}"
      # end
      new_unit = self.unit

      # ensure supplier price is adjusted (eg, if we have UQ of 6 X 1L, but supplier price is UQ 1 x 1L)
      if ((new_price * new_unit_quantity) - new_supplier_price).abs > (new_unit_quantity * 0.1) # account for small rounding errors
        new_supplier_price = new_price * new_unit_quantity
      end
    else
      # puts "no converted values, using supplier values"
      new_price = new_article.price
      new_unit_quantity = new_article.unit_quantity
      new_unit = new_article.unit
    end

    # sometimes the supplier deposit is not known, so only update it if a nonzero value is given
    new_deposit = new_article.deposit != 0 ? new_article.deposit : deposit

    return Article.compare_attributes(
      {
        :name => [self.name, new_article.name],
        :manufacturer => [self.manufacturer, new_article.manufacturer.to_s],
        :origin => [self.origin, new_article.origin],
        :unit => [self.unit, new_unit],
        :price => [self.price.to_f.round(2), new_price.to_f.round(2)],
        :supplier_price => [self.supplier_price.to_f.round(2), new_supplier_price.to_f.round(2)],
        :tax => [self.tax, new_article.tax],
        :deposit => [self.deposit.to_f.round(2), new_deposit.to_f.round(2)],
        # take care of different num-objects.
        :unit_quantity => [self.unit_quantity.to_s.to_f, new_unit_quantity.to_s.to_f],
        :note => [self.note.to_s, new_article.note.to_s]
      }
    )
  end

  # Compare attributes from two different articles.
  #
  # This is used for auto-synchronization
  # @param attributes [Hash<Symbol, Array>] Attributes with old and new values
  # @return [Hash<Symbol, Object>] Changed attributes with new values
  def self.compare_attributes(attributes)
    unequal_attributes = attributes.select { |name, values| values[0] != values[1] && !(values[0].blank? && values[1].blank?) }
    Hash[unequal_attributes.to_a.map { |a| [a[0], a[1].last] }]
  end

  # to get the correspondent shared article
  def shared_article(supplier = self.supplier)
    # self.order_number.blank? and return nil
    # @shared_article ||= supplier.shared_supplier.find_article_by_number(self.order_number) rescue nil
    if @shared_article.nil?
      unless supplier.shared_supplier.nil?
        @shared_article ||= supplier.shared_supplier.find_article_by_number(self.order_number)

        # this is a sanity check in case the sku points to the wrong article (happened due to our db getting messed up)
        # note we may go back to using this one at the end of this block
        @shared_article = nil if @shared_article && @shared_article.name != self.name

        @shared_article ||= supplier.shared_supplier.find_article_by_name_origin_manufacture(self.name, self.origin, self.manufacturer)
        @shared_article ||= supplier.shared_supplier.find_article_by_name_manufacture(self.name, self.manufacturer)

        # ok, if we had cleared this because of the 'sanity check' above, but could not find it via the other lookups,
        # then go back to the order number version if it exists
        @shared_article ||= supplier.shared_supplier.find_article_by_number(self.order_number)
      end
      if @shared_article
        if @shared_article.linked_to.nil?
          @shared_article.linked_to = self
        else
          # raise "already linked to #{@shared_article.linked_to} not #{self.id}" unless @shared_article.linked_to == self
          if @shared_article.linked_to != self
            puts "already linked to #{@shared_article.linked_to} not #{self.id}"
            @shared_article = false
          end
        end
      end
    end
    @shared_article
  end

  # convert units in foodcoop-size
  # uses unit factors in app_config.yml to calc the price/unit_quantity
  # returns new price and unit_quantity in array, when calc is possible => [price, unit_quanity]
  # returns false if units aren't foodsoft-compatible
  # returns nil if units are eqal
  def convert_units(new_article = shared_article)

    if true # supplier && supplier.name == 'Pro Organics'
      if unit == new_article.unit && unit_quantity == new_article.unit_quantity
        # puts "unit '#{unit} x #{unit_quantity}' == new_article.unit '#{new_article.unit} x #{new_article.unit_quantity}' no conversion needed for #{name}"
        return nil
      end
      fc_unit = (::Unit.new(unit.downcase) rescue nil)
      supplier_unit = (::Unit.new(new_article.unit.downcase) rescue nil)
      fc_uq = unit_quantity
      supplier_uq = new_article.unit_quantity
      if fc_unit && supplier_unit && fc_unit =~ supplier_unit
        # conversion_factor = ((supplier_unit*supplier_uq) / (fc_unit*fc_uq)).to_base.to_r
        conversion_factor = (supplier_unit/fc_unit).scalar
        new_price = new_article.price / conversion_factor
        # new_unit_quantity = new_article.unit_quantity * conversion_factor
        new_unit_quantity = fc_uq
        # puts "Pro: fc_unit =~ supplier_unit is true. conversion (#{conversion_factor}) converting #{[new_price.to_f, new_unit_quantity.to_f]}"
        return [new_price, new_unit_quantity]
      else
        # puts "Pro: fc_unit (#{fc_unit}) =~ supplier_unit (#{supplier_unit}) is not true (units changed?), no conversion possible"
        return false
      end
    end


    if unit == new_article.unit
      # puts "unit '#{unit}' == new_article.unit '#{new_article.unit}' no conversion needed for #{name}"
      return nil
    end



    # legacy, used by foodcoops in Germany
    if new_article.unit == "KI" && unit == "ST" # 'KI' means a box, with a different amount of items in it
      # try to match the size out of its name, e.g. "banana 10-12 St" => 10
      new_unit_quantity = /[0-9\-\s]+(St)/.match(new_article.name).to_s.to_i
      if new_unit_quantity && new_unit_quantity > 0
        new_price = (new_article.price / new_unit_quantity.to_f).round(2)
        return [new_price, new_unit_quantity]
      else
        return false
      end
    end

    # use ruby-units to convert
    fc_unit = (::Unit.new(unit.downcase) rescue nil)
    supplier_unit = (::Unit.new(new_article.unit.downcase) rescue nil)
    # puts "fc_unit=#{fc_unit} (uq=#{unit_quantity}) supplier_unit=#{supplier_unit} (uq=#{new_article.unit_quantity})  fc_unit =~ supplier_unit=#{fc_unit =~ supplier_unit} of #{name}"
    # fc_unit =~ supplier_unit is checking the type of unit - eg 1LB =~ 5LB is true
    if fc_unit && supplier_unit && fc_unit =~ supplier_unit
      #if fc_unit && supplier_unit && (fc_unit != supplier_unit || new_article.unit_quantity != unit_quantity)
      conversion_factor = (supplier_unit / fc_unit).to_base.to_r
      new_price = new_article.price / conversion_factor
      new_unit_quantity = new_article.unit_quantity * conversion_factor
      # puts "fc_unit =~ supplier_unit is true. conversion (#{conversion_factor}) converting #{[new_price.to_f, new_unit_quantity.to_f]}"
      return [new_price, new_unit_quantity]
    else
      # puts "fc_unit (#{fc_unit}) =~ supplier_unit (#{supplier_unit}) is not true (units changed?), no conversion possible"
      return false
    end
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    check_article_in_use
    update_column :deleted_at, Time.now
  end

  def description
    "#{ActionController::Base.helpers.number_to_currency(price)} #{name} #{manufacturer} #{origin} #{note} #{unit_quantity} #{unit}"
  end

  protected

  # Checks if the article is in use before it will deleted
  def check_article_in_use
    raise I18n.t('articles.model.error_in_use', :article => self.name.to_s) if self.in_open_order
  end

  # Create an ArticlePrice, when the price-attr are changed.
  def update_price_history
    if price_changed?
      article_prices.build(
        :price => price,
        :tax => tax,
        :deposit => deposit,
        :unit_quantity => unit_quantity,
        :supplier_price => supplier_price
      )
    end
  end

  def price_changed?
    changed.detect { |attr| attr == 'price' || 'tax' || 'deposit' || 'unit_quantity' || 'supplier_price' } ? true : false
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
    elsif matches.where(unit: unit, unit_quantity: unit_quantity, manufacturer: manufacturer, origin: origin).any?
      errors.add :name, :taken_with_unit
    end
  end

end
