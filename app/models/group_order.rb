# == Schema Information
# Schema version: 20090102171850
#
# Table name: group_orders
#
#  id                 :integer(4)      not null, primary key
#  order_group_id     :integer(4)      default(0), not null
#  order_id           :integer(4)      default(0), not null
#  price              :decimal(8, 2)   default(0.0), not null
#  lock_version       :integer(4)      default(0), not null
#  updated_on         :datetime        not null
#  updated_by_user_id :integer(4)      default(0), not null
#

# A GroupOrder represents an Order placed by an OrderGroup.
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
