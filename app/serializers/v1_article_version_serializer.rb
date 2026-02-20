class V1ArticleVersionSerializer < ActiveModel::Serializer
  attributes :id, :name, :supplier_id, :supplier_name, :unit, :unit_quantity, :note, :manufacturer, :origin, :article_category_id

  def unit
    object.supplier_order_unit || object.unit
  end

  def supplier_id
    object.article.try(:supplier_id)
  end

  def supplier_name
    object.article.supplier.try(:name)
  end

  def unit_quantity
    object.unit_quantity.round.to_i
  end
end
