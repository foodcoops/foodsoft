# An OrderArticle represents a single Article that is part of an Order.
# 
# Properties:
# * order_id (int): association to the Order
# * article_id (int): association to the Article
# * quantity (int): number of items ordered by all OrderGroups for this order
# * tolerance (int): number of items ordered as tolerance by all OrderGroups for this order
# * units_to_order (int): number of packaging units to be ordered according to the order quantity/tolerance
#
class OrderArticle < ActiveRecord::Base

  belongs_to :order
  belongs_to :article
  has_many :group_order_articles, :dependent => :destroy

  validates_presence_of :order_id
  validates_presence_of :article_id
  validates_uniqueness_of :article_id, :scope => :order_id   #  an article can only have one record per order

  private
  
    def validate
       errors.add(:article, "muss angegeben sein und einen aktuellen Preis haben") if !(article = Article.find(article_id)) || article.gross_price.nil?
    end
    
end
