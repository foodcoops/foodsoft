class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :name
  attributes :supplier_id, :supplier_name
  attributes :unit, :unit_quantity, :note, :manufacturer, :origin, :article_category_id

  def supplier_name
    object.supplier.try(:name)
  end
end
