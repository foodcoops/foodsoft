class OrderArticleSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :price
  attributes :quantity, :tolerance, :units_to_order

  has_one :article_version

  def price
    object.article_version.fc_price.to_f
  end
end
