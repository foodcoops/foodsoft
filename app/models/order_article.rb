# == Schema Information
# Schema version: 20090120184410
#
# Table name: order_articles
#
#  id               :integer(4)      not null, primary key
#  order_id         :integer(4)      default(0), not null
#  article_id       :integer(4)      default(0), not null
#  quantity         :integer(4)      default(0), not null
#  tolerance        :integer(4)      default(0), not null
#  units_to_order   :integer(4)      default(0), not null
#  lock_version     :integer(4)      default(0), not null
#  article_price_id :integer(4)
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

  named_scope :ordered, :conditions => "units_to_order >= 1"

  # This method returns either the Article or the ArticlePrice
  # The latter will be set, when the the order is finished
  def price
    article_price || article
  end
  
  private
  
    def validate
       errors.add(:article, "muss angegeben sein und einen aktuellen Preis haben") if !(article = Article.find(article_id)) || article.fc_price.nil?
    end
    
end
