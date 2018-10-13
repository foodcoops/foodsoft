class GroupOrderArticleSerializer < ActiveModel::Serializer
  attributes :id, :order_article_id
  attributes :quantity, :tolerance, :result, :total_price

  def total_price
    object.total_price.to_f
  end
end
