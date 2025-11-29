class ArticleVersionSerializer < ActiveModel::Serializer
  attributes :id, :name, :supplier_id, :supplier_name, :unit, :supplier_order_unit, :price_unit, :billing_unit, :group_order_unit, :group_order_granularity, :minimum_order_quantity, :note, :manufacturer, :origin, :article_category_id

  has_many :article_unit_ratios

  def supplier_id
    object.article.try(:supplier_id)
  end

  def supplier_name
    object.article.supplier.try(:name)
  end
end
