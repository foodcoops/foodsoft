require 'csv'

class OrderCsv < RenderCsv
  def header
    params = @options[:custom_csv]
    arr = if params.nil?
            [
              OrderArticle.human_attribute_name(:units_to_order),
              Article.human_attribute_name(:order_number),
              Article.human_attribute_name(:name),
              Article.human_attribute_name(:unit),
              Article.human_attribute_name(:unit_quantity_short),
              ArticlePrice.human_attribute_name(:price),
              OrderArticle.human_attribute_name(:total_price)
            ]
          else
            [
              params[:first],
              params[:second],
              params[:third],
              params[:fourth],
              params[:fifth],
              params[:sixth],
              params[:seventh]
            ]
          end
  end

  def data
    @object.order_articles.ordered.includes(%i[article article_price]).all.map do |oa|
      yield [
        match_params(oa, header[0]),
        match_params(oa, header[1]),
        match_params(oa, header[2]),
        match_params(oa, header[3]),
        match_params(oa, header[4]),
        match_params(oa, header[5]),
        match_params(oa, header[6])
      ]
    end
  end

  def match_params(object, attribute)
    case attribute
    when OrderArticle.human_attribute_name(:units_to_order)
      object.units_to_order
    when Article.human_attribute_name(:order_number)
      object.article.order_number
    when Article.human_attribute_name(:name)
      object.article.name
    when Article.human_attribute_name(:unit)
      object.article.unit
    when Article.human_attribute_name(:unit_quantity_short)
      object.price.unit_quantity > 1 ? object.price.unit_quantity : nil
    when ArticlePrice.human_attribute_name(:price)
      number_to_currency(object.price.price * object.price.unit_quantity)
    when OrderArticle.human_attribute_name(:total_price)
      number_to_currency(object.total_price)
    end
  end
end
