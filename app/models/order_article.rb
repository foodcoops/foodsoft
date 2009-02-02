# == Schema Information
# Schema version: 20090119155930
#
# Table name: order_articles
#
#  id               :integer         not null, primary key
#  order_id         :integer         default(0), not null
#  article_id       :integer         default(0), not null
#  quantity         :integer         default(0), not null
#  tolerance        :integer         default(0), not null
#  units_to_order   :integer         default(0), not null
#  lock_version     :integer         default(0), not null
#  article_price_id :integer
#

# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ActiveRecord::Base

  belongs_to :order
  belongs_to :article
  belongs_to :article_price
  has_many :group_order_articles, :dependent => :destroy

  validates_presence_of :order_id
  validates_presence_of :article_id
  validates_uniqueness_of :article_id, :scope => :order_id   #  an article can only have one record per order
  validate :article_and_price_exist

  named_scope :ordered, :conditions => "units_to_order >= 1"

  # TODO: How to create/update articles/article_prices during balancing
#  # Accessors for easy create of new order_articles in balancing process
#  attr_accessor :name, :order_number, :units_to_order, :unit_quantity, :unit, :net_price, :tax, :deposit
#
#  before_validation_on_create :create_new_article

  # This method returns either the Article or the ArticlePrice
  # The latter will be set, when the the order is finished
  def price
    article_price || article
  end
  
  # Count quantities of belonging group_orders. 
  # In balancing this can differ from ordered (by supplier) quantity for this article.
  def group_orders_sum
    quantity = group_order_articles.collect(&:quantity).sum
    {:quantity => quantity, :price => quantity * price.fc_price}
  end

  private
  
  def article_and_price_exist
     errors.add(:article, "muss angegeben sein und einen aktuellen Preis haben") if !(article = Article.find(article_id)) || article.fc_price.nil?
  end

#  def create_new_article
#    old_article = order.articles.find_by_name(name) # Check if there is already an Article with this name
#    unless old_article
#      self.article.build
#    end
#  end
end
