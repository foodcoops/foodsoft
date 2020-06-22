class ArticlesCsv < RenderCSV
  include ApplicationHelper

  def header
    [
      '',
      Article.human_attribute_name(:order_number),
      Article.human_attribute_name(:name),
      Article.human_attribute_name(:note),
      Article.human_attribute_name(:manufacturer),
      Article.human_attribute_name(:origin),
      Article.human_attribute_name(:unit),
      Article.human_attribute_name(:price),
      Article.human_attribute_name(:tax),
      Article.human_attribute_name(:deposit),
      Article.human_attribute_name(:unit_quantity),
      '',
      '',
      Article.human_attribute_name(:article_category),
    ]
  end

  def data
    @object.each do |o|
      yield [
        '',
        o.order_number,
        o.name,
        o.note,
        o.manufacturer,
        o.origin,
        o.unit,
        o.price,
        o.tax,
        o.deposit,
        o.unit_quantity,
        '',
        '',
        o.article_category.try(:name),
      ]
    end
  end
end
