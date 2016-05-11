class GroupOrderArticleSerializer < ActiveModel::Serializer
  attributes :id, :order_article_id
  attributes :quantity, :tolerance, :result, :total_price

  def total_price
    # make sure BigDecimal is serialized as a number
    object.total_price.to_f
  end
end
