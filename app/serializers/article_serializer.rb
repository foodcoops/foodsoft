class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :name, :unit, :unit_quantity, :note, :manufacturer, :origin, :article_category_id
end
