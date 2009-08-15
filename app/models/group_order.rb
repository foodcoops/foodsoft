# == Schema Information
#
# Table name: group_orders
#
#  id                 :integer         not null, primary key
#  ordergroup_id      :integer         default(0), not null
#  order_id           :integer         default(0), not null
#  price              :decimal(8, 2)   default(0.0), not null
#  lock_version       :integer         default(0), not null
#  updated_on         :datetime        not null
#  updated_by_user_id :integer
#

# A GroupOrder represents an Order placed by an Ordergroup.
class GroupOrder < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :ordergroup
  has_many :group_order_articles, :dependent => :destroy
  has_many :order_articles, :through => :group_order_articles
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_user_id"

  validates_presence_of :order_id
  validates_presence_of :ordergroup_id
  validates_numericality_of :price
  validates_uniqueness_of :ordergroup_id, :scope => :order_id   # order groups can only order once per order

  named_scope :open, lambda { {:conditions => ["order_id IN (?)", Order.open.collect(&:id)]} }
  named_scope :finished, lambda { {:conditions => ["order_id IN (?)", Order.finished_not_closed.collect(&:id)]} }
  
  # Updates the "price" attribute.
  # Until the order is finished this will be the maximum price or
  # the minimum price depending on configuration. When the order is finished it
  # will be the value depending of the article results.
  def update_price!
    total = 0
    for article in group_order_articles.find(:all, :include => :order_article)
      unless order.finished?
        if Foodsoft.config[:tolerance_is_costly]
          total += article.order_article.article.fc_price * (article.quantity + article.tolerance)
        else
          total += article.order_article.article.fc_price * article.quantity
        end
      else
        total += article.order_article.price.fc_price * article.result
      end
    end
    update_attribute(:price, total)
  end

end
