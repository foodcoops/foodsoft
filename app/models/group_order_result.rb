# OrderGroups, which participate on a specific order will have a line
# Properties:
# * order_id, int
# * group_name, the name of the group
# * price, decimal
# * group_order_article_results: collection of associated GroupOrderArticleResults
# 
class GroupOrderResult < ActiveRecord::Base
  # gettext-option
  untranslate_all
  
  belongs_to :order
  has_many :group_order_article_results, :dependent => :destroy
  
  # Calculates the Order-Price for the OrderGroup and updates the price-attribute
  def updatePrice
    total = 0
    group_order_article_results.each do |result|
      total += result.order_article_result.gross_price * result.quantity
    end
    update_attribute(:price, total)
  end
end
