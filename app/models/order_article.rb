# == Schema Information
# Schema version: 20090102171850
#
# Table name: order_articles
#
#  id             :integer(4)      not null, primary key
#  order_id       :integer(4)      default(0), not null
#  article_id     :integer(4)      default(0), not null
#  quantity       :integer(4)      default(0), not null
#  tolerance      :integer(4)      default(0), not null
#  units_to_order :integer(4)      default(0), not null
#  lock_version   :integer(4)      default(0), not null
#

# An OrderArticle represents a single Article that is part of an Order.
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
