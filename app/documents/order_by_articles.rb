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
      dimrows = []
      for goa in order_article.group_order_articles.ordered
        rows << [goa.group_order.ordergroup.name,
                  "#{goa.quantity} + #{goa.tolerance}",
                 goa.result,
                 number_with_precision(goa.total_price(order_article), precision: 2)]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      rows.unshift I18n.t('documents.order_by_articles.rows') # table header

      text "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity.to_s} | #{number_with_precision(order_article.price.fc_price, precision: 2)})",
           style: :bold, size: fontsize(10)
      table rows, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
        table.column(0).width = 200
        table.columns(1..3).align = :right
        table.column(2).font_style = :bold
        table.cells.border_width = 1
        table.cells.border_color = '666666'
        table.rows(0).border_bottom_width = 2
        # dim rows which were ordered but not received
        dimrows.each { |ri| table.row(ri).text_color = '999999' }
      end

      down_or_page
    end
  end

end
