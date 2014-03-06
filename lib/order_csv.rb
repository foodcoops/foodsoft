require 'csv'

class OrderCsv
  include ActionView::Helpers::NumberHelper

  def initialize(order, options={})
    @order = order
  end

  def to_csv
    CSV.generate do |csv|
      # header
      csv << [
               OrderArticle.human_attribute_name(:units_to_order),
               Article.human_attribute_name(:order_number),
               Article.human_attribute_name(:name),
               Article.human_attribute_name(:unit),
               ArticlePrice.human_attribute_name(:price),
               OrderArticle.human_attribute_name(:total_price)
             ]
      # data
      @order.order_articles.ordered.includes([:article, :article_price]).all.map do |oa|
        csv << [
                 oa.units_to_order,
                 oa.article.order_number,
                 oa.article.name,
                 oa.article.unit + (oa.price.unit_quantity > 1 ? " × #{oa.price.unit_quantity}" : ''),
                 number_to_currency(oa.article_price.price * oa.article_price.unit_quantity),
                 number_to_currency(oa.total_price)
               ]
      end
    end
  end

  # Helper method to test pdf via rails console: OrderCsv.new(order).save_tmp
  def save_tmp
    File.open("#{Rails.root}/tmp/#{self.class.to_s.underscore}.csv", 'w') {|f| f.write(to_csv.force_encoding("UTF-8")) }
  end
end
