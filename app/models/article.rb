# encoding: utf-8
class Article < ActiveRecord::Base
  extend ActiveSupport::Memoizable    # Ability to cache method results. Use memoize :expensive_method

  # Replace numeric seperator with database format
  localize_input_of :price, :tax, :deposit

  # Associations
  belongs_to :supplier
  belongs_to :article_category
  has_many :article_prices, :order => "created_at DESC"

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :available, -> { undeleted.where(availability: true) }
  scope :not_in_stock, :conditions => {:type => nil}

  # Validations
  validates_presence_of :name, :unit, :price, :tax, :deposit, :unit_quantity, :supplier_id, :article_category
  validates_length_of :name, :in => 4..60
  validates_length_of :unit, :in => 2..15
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_numericality_of :unit_quantity, :greater_than => 0
  validates_numericality_of :deposit, :tax
  validates_uniqueness_of :name, :scope => [:supplier_id, :deleted_at, :type, :unit]
  
  # Callbacks
  before_save :update_price_history
  before_destroy :check_article_in_use

  def title
    "#{name} (#{unit})"
  end
  
  # The financial gross, net plus tax and deposti
  def gross_price
    ((price + deposit) * (tax / 100 + 1)).round(2)
  end

  # The price for the foodcoop-member.
  def fc_price
    (gross_price  * (FoodsoftConfig[:price_markup] / 100 + 1)).round(2)
  end
  
  # Returns true if article has been updated at least 2 days ago
  def recently_updated
    updated_at > 2.days.ago
  end
  
  # If the article is used in an open Order, the Order will be returned.
  def in_open_order
    order_articles = OrderArticle.all(:conditions => ['order_id IN (?)', Order.open.collect(&:id)])
    order_article = order_articles.detect {|oa| oa.article_id == id }
    order_article ? order_article.order : nil
  end
  memoize :in_open_order
  
  # Returns true if the article has been ordered in the given order at least once
  def ordered_in_order?(order)
    order.order_articles.where(article_id: id).where('quantity > 0').one?
  end
  
  # this method checks, if the shared_article has been changed
  # unequal attributes will returned in array
  # if only the timestamps differ and the attributes are equal, 
  # false will returned and self.shared_updated_on will be updated
  def shared_article_changed?
    # skip early if the timestamp hasn't changed
    unless self.shared_updated_on == self.shared_article.updated_on
      
      # try to convert units
      # convert supplier's price and unit_quantity into fc-size
      new_price, new_unit_quantity = self.convert_units
      new_unit = self.unit
      unless new_price and new_unit_quantity
        # if convertion isn't possible, take shared_article-price/unit_quantity
        new_price, new_unit_quantity, new_unit = self.shared_article.price, self.shared_article.unit_quantity, self.shared_article.unit
      end
      
      # check if all attributes differ
      unequal_attributes = Article.compare_attributes(
        {
          :name => [self.name, self.shared_article.name],
          :manufacturer => [self.manufacturer, self.shared_article.manufacturer.to_s],
          :origin => [self.origin, self.shared_article.origin],
          :unit => [self.unit, new_unit],
          :price => [self.price, new_price],
          :tax => [self.tax, self.shared_article.tax],
          :deposit => [self.deposit, self.shared_article.deposit],
          # take care of different num-objects.
          :unit_quantity => [self.unit_quantity.to_s.to_f, new_unit_quantity.to_s.to_f],
          :note => [self.note.to_s, self.shared_article.note.to_s]
        }
      )
      if unequal_attributes.empty?            
        # when attributes not changed, update timestamp of article
        self.update_attribute(:shared_updated_on, self.shared_article.updated_on)
        false
      else
        unequal_attributes
      end
    end
  end
  
  # compare attributes from different articles. used for auto-synchronization
  # returns array of symbolized unequal attributes
  def self.compare_attributes(attributes)
    unequal_attributes = attributes.select { |name, values| values[0] != values[1] }
    unequal_attributes.collect { |pair| pair[0] }
  end
  
  # to get the correspondent shared article
  def shared_article
    @shared_article ||= self.supplier.shared_supplier.shared_articles.find_by_number(self.order_number)
  end
  
  # convert units in foodcoop-size
  # uses unit factors in app_config.yml to calc the price/unit_quantity
  # returns new price and unit_quantity in array, when calc is possible => [price, unit_quanity]
  # returns false if units aren't foodsoft-compatible
  # returns nil if units are eqal
  def convert_units
    if unit != shared_article.unit
      if shared_article.unit == "KI" and unit == "ST" # 'KI' means a box, with a different amount of items in it
        # try to match the size out of its name, e.g. "banana 10-12 St" => 10
        new_unit_quantity = /[0-9\-\s]+(St)/.match(shared_article.name).to_s.to_i
        if new_unit_quantity and new_unit_quantity > 0
          new_price = (shared_article.price/new_unit_quantity.to_f).round(2)
          [new_price, new_unit_quantity]
        else
          false
        end
      else # get factors for fc and supplier
        fc_unit_factor = FoodsoftConfig[:units][self.unit]
        supplier_unit_factor = FoodsoftConfig[:units][self.shared_article.unit]
        if fc_unit_factor and supplier_unit_factor
          convertion_factor = fc_unit_factor / supplier_unit_factor
          new_price = BigDecimal((convertion_factor * shared_article.price).to_s).round(2)
          new_unit_quantity = ( 1 / convertion_factor) * shared_article.unit_quantity
          [new_price, new_unit_quantity]
        else
          false
        end
      end
    else
      nil
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
    raise I18n.t('articles.model.error_in_use', :article => self.name.to_s) if self.in_open_order
  end

  # Create an ArticlePrice, when the price-attr are changed.
  def update_price_history
    if price_changed?
      article_prices.build(
        :price => price,
        :tax => tax,
        :deposit => deposit,
        :unit_quantity => unit_quantity
      )
    end
  end

  def price_changed?
    changed.detect { |attr| attr == 'price' || 'tax' || 'deposit' || 'unit_quantity' } ? true : false
  end
end
