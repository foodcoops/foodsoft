# == Schema Information
# Schema version: 20090102171850
#
# Table name: group_order_article_results
#
#  id                      :integer(4)      not null, primary key
#  order_article_result_id :integer(4)      default(0), not null
#  group_order_result_id   :integer(4)      default(0), not null
#  quantity                :decimal(6, 3)   default(0.0)
#  tolerance               :integer(4)
#

# An GroupOrderArticleResult represents a group-order for a single Article and its quantities, 
# according to the order quantity/tolerance.
# The GroupOrderArticleResult is part of a finished Order, see OrderArticleResult.
#
class GroupOrderArticleResult < ActiveRecord::Base

  belongs_to :order_article_result
  belongs_to :group_order_result
  
  validates_presence_of :order_article_result, :group_order_result, :quantity
  validates_numericality_of :quantity, :minimum => 0
  
  # updates the price attribute for the appropriate GroupOrderResult
  after_update {|result| result.group_order_result.updatePrice }
  after_destroy {|result| result.group_order_result.updatePrice }
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def quantity=(quantity)
    self[:quantity] = String.delocalized_decimal(quantity)
  end
  
end
