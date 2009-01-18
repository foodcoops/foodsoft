# == Schema Information
# Schema version: 20090115232435
#
# Table name: articles
#
#  id                  :integer(4)      not null, primary key
#  name                :string(255)     default(""), not null
#  supplier_id         :integer(4)      default(0), not null
#  article_category_id :integer(4)      default(0), not null
#  unit                :string(255)     default(""), not null
#  note                :string(255)
#  availability        :boolean(1)      default(TRUE), not null
#  manufacturer        :string(255)
#  origin              :string(255)
#  shared_updated_on   :datetime
#  net_price           :decimal(8, 2)
#  gross_price         :decimal(8, 2)   default(0.0), not null
#  tax                 :float
#  deposit             :decimal(8, 2)   default(0.0)
#  unit_quantity       :integer(4)      default(1), not null
#  order_number        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  quantity            :decimal(6, 2)   default(0.0)
#

class Article < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :article_category

  named_scope :in_stock, :conditions => "quantity > 0", :order => 'suppliers.name', :include => :supplier
  
  validates_presence_of :name, :unit, :net_price, :tax, :deposit, :unit_quantity, :supplier_id
  validates_length_of :name, :in => 4..60
  validates_length_of :unit, :in => 2..15
  validates_numericality_of :net_price, :greater_than => 0
  validates_numericality_of :deposit, :tax
  
  # calculate the gross_price
  before_save :calc_gross_price
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def net_price=(net_price)
    self[:net_price] = String.delocalized_decimal(net_price)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def tax=(tax)
    self[:tax] = String.delocalized_decimal(tax)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit=(deposit)
    self[:deposit] = String.delocalized_decimal(deposit)
  end
  
  # calculate the fc price and sets the attribute
  def calc_gross_price
    self.gross_price = ((net_price + deposit) * (tax / 100 + 1)) * (APP_CONFIG[:price_markup] / 100 + 1)
  end
  
  # Returns true if article has been updated at least 2 days ago
  def recently_updated
    updated_at > 2.days.ago
  end
  
  # Returns how many units of this article need to be ordered given the specified order quantity and tolerance.
  # This is determined by calculating how many units can be ordered from the given order quantity, using
  # the tolerance to order an additional unit if the order quantity is not quiet sufficient. 
  # There must always be at least one item in a unit that is an ordered quantity (no units are ever entirely 
  # filled by tolerance items only).  
  # 
  # Example:
  # 
  # unit_quantity | quantity | tolerance | calculateOrderQuantity
  # --------------+----------+-----------+-----------------------
  #      4        |    0     |     2     |           0
  #      4        |    0     |     5     |           0
  #      4        |    2     |     2     |           1
  #      4        |    4     |     2     |           1
  #      4        |    4     |     4     |           1
  #      4        |    5     |     3     |           2
  #      4        |    5     |     4     |           2
  # 
  def calculateOrderQuantity(quantity, tolerance = 0)
    unitSize = unit_quantity
    units = quantity / unitSize
    remainder = quantity % unitSize
    units += ((remainder > 0) && (remainder + tolerance >= unitSize) ? 1 : 0) 
  end

  # If the article is used in an active Order, the Order will returned.
  def inUse
    Order.find(:all, :conditions => 'finished = 0').each do |order|
      if order.articles.find_by_id(self)
        @order = order
        break
      end
    end
    return @order if @order
  end
  
  # Checks if the article is in use before it will deleted
  def before_destroy
    raise self.name.to_s + _(" cannot be deleted. The article is used in a current order!") if self.inUse
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
          :net_price => [self.net_price, new_price],
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
        fc_unit_factor = APP_CONFIG[:units][self.unit]
        supplier_unit_factor = APP_CONFIG[:units][self.shared_article.unit]
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
  
  # Returns Articles in a nested Array, grouped by category and ordered by article name.
  # The array has the following form:
  # e.g: [["drugs",[teethpaste, toiletpaper]], ["fruits" => [apple, banana, lemon]]]
  # TODO: force article to belong to a category and remove this complicated implementation!
  def self.group_by_category(articles)
    articles_by_category = {}
    ArticleCategory.find(:all).each do |category|
      articles_by_category.merge!(category.name.to_s => articles.select {|article| article.article_category and article.article_category.id == category.id })
    end
    # add articles without a category
    articles_by_category.merge!( "--" => articles.select {|article| article.article_category == nil})
    # return "clean" hash, sorted by category.name
    return articles_by_category.reject {|category, array| array.empty?}.sort

    # it could be so easy ... but that doesn't work for empty category-ids...
    # articles.group_by {|a| a.article_category}.sort {|a, b| a[0].name <=> b[0].name}
  end

  def update_quantity(amount)
    update_attribute :quantity, quantity + amount
  end

end
