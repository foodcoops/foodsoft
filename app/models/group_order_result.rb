# == Schema Information
# Schema version: 20090102171850
#
# Table name: group_order_results
#
#  id         :integer(4)      not null, primary key
#  order_id   :integer(4)      default(0), not null
#  group_name :string(255)     default(""), not null
#  price      :decimal(8, 2)   default(0.0), not null
#

# Ordergroups, which participate on a specific order will have a line
class GroupOrderResult < ActiveRecord::Base
  
  belongs_to :order
  has_many :group_order_article_results, :dependent => :destroy
  
  # Calculates the Order-Price for the Ordergroup and updates the price-attribute
  def updatePrice
    total = 0
    group_order_article_results.each do |result|
      total += result.order_article_result.gross_price * result.quantity
    end
    update_attribute(:price, total)
  end
end
