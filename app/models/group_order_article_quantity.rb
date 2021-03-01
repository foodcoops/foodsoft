# stores the quantity, tolerance and timestamp of an GroupOrderArticle
# Considers every update of an article-order, so may rows for one group_order_article ar possible.

class GroupOrderArticleQuantity < ApplicationRecord
  belongs_to :group_order_article

  validates_presence_of :group_order_article_id
end
