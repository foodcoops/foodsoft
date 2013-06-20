# encoding: utf-8
class OrderByArticles < OrderPdf

  def filename
    I18n.t('documents.order_by_articles.filename', :name => @order.name, :date => @order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => @order.name,
      :date => @order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    @order.order_articles.ordered.each do |order_article|
      rows = []
      for goa in order_article.group_order_articles
        next if goa.result == 0
        rows << [goa.group_order.ordergroup.name,
                 goa.result,
                 number_with_precision(order_article.price.fc_price * goa.result, precision: 2)]
      end
      next if rows.length == 0
      rows.unshift I18n.t('documents.order_by_articles.rows') # table header

      text "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity.to_s} | #{number_with_precision(order_article.price.fc_price, precision: 2)})",
           style: :bold, size: 10
      table rows, column_widths: [200,40,40], cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
        table.columns(1..2).align = :right
        table.cells.border_width = 1
        table.cells.border_color = '666666'
      end
      move_down 10
    end
  end

end
