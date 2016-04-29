class GroupOrderArticleSerializer < ActiveModel::Serializer
  attributes :id, :order_article_id
  attributes :quantity, :tolerance, :result
end
