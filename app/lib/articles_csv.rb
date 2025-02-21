class ArticlesCsv < RenderCsv
  include ApplicationHelper

  def header
    [
      Article.human_attribute_name(:availability_short),
      Article.human_attribute_name(:order_number),
      Article.human_attribute_name(:name),
      Article.human_attribute_name(:supplier_order_unit),
      Article.human_attribute_name(:custom_unit),
      Article.human_attribute_name(:ratios_to_supplier_order_unit),
      Article.human_attribute_name(:minimum_order_quantity),
      Article.human_attribute_name(:billing_unit),
      Article.human_attribute_name(:group_order_granularity),
      Article.human_attribute_name(:group_order_unit),
      Article.human_attribute_name(:price),
      Article.human_attribute_name(:price_unit),
      Article.human_attribute_name(:tax),
      Article.human_attribute_name(:deposit),
      Article.human_attribute_name(:note),
      Article.human_attribute_name(:article_category),
      Article.human_attribute_name(:origin),
      Article.human_attribute_name(:manufacturer)
    ]
  end

  def data
    @object.each do |article|
      yield [
        article.availability ? I18n.t('simple_form.yes') : I18n.t('simple_form.no'),
        article.order_number,
        article.name,
        ArticleUnitsLib.get_translated_name_for_code(article.supplier_order_unit),
        article.unit,
        get_csv_ratios(article),
        article.minimum_order_quantity,
        ArticleUnitsLib.get_translated_name_for_code(article.billing_unit),
        article.group_order_granularity,
        ArticleUnitsLib.get_translated_name_for_code(article.group_order_unit),
        article.price_unit_price,
        ArticleUnitsLib.get_translated_name_for_code(article.price_unit),
        article.tax,
        article.deposit,
        article.note,
        article.article_category.try(:name),
        article.origin,
        article.manufacturer
      ]
    end
  end

  def get_csv_ratios(article)
    previous_quantity = nil
    article.article_unit_ratios.each_with_index.map do |ratio, _index|
      quantity = previous_quantity.nil? ? ratio.quantity : ratio.quantity / previous_quantity
      previous_quantity = ratio.quantity
      "#{quantity} #{escape_csv_ratio(ArticleUnitsLib.get_translated_name_for_code(ratio.unit))}"
    end.join(', ')
  end

  def escape_csv_ratio(str)
    str.gsub('\\', '\\\\').gsub(',', '\\,')
  end
end
