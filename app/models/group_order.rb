# A GroupOrder represents an Order placed by an OrderGroup.
# 
# Properties:
# * order_id (int): association to the Order
# * order_group_id (int): association to the OrderGroup
# * group_order_articles: collection of associated GroupOrderArticles
# * order_articles: collection of associated OrderArticles (through GroupOrderArticles)
# * price (decimal): the price of this GroupOrder (either maximum price if current order or the actual price if finished order)
# * lock_version (int): ActiveRecord optimistic locking column
# * updated_by (User): the user who last updated this order
#
class GroupOrder < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :order_group
  has_many :group_order_articles, :dependent => :destroy
  has_many :order_articles, :through => :group_order_articles
  has_many :group_order_article_results
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_user_id"

  validates_presence_of :order_id
  validates_presence_of :order_group_id
  validates_presence_of :updated_by
  validates_numericality_of :price
  validates_uniqueness_of :order_group_id, :scope => :order_id   # order groups can only order once per order

  # Updates the "price" attribute.
  # This will be the maximum value of a current order
  def updatePrice
    total = 0
    for article in group_order_articles.find(:all, :include => :order_article)
      total += article.order_article.article.gross_price * (article.quantity + article.tolerance)            
    end        
    self.price = total
  end

end
