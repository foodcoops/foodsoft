# encoding: utf-8
class OrderByArticles < OrderPdf

  def filename
    "Bestellung #{@order.name}-#{@order.ends.to_date} - Artikelsortierung.pdf"
  end

  def title
    "Artikelsortierung der Bestellung: #{@order.name}, beendet am #{@order.ends.strftime('%d.%m.%Y')}"
  end

  def body
    @order.order_articles.ordered.each do |order_article|
      text "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity.to_s} | #{number_with_precision(order_article.price.fc_price, precision: 2)})",
           style: :bold, size: 10
      rows = []
      rows << %w(Bestellgruppe Menge Preis)
      for goa in order_article.group_order_articles
        rows << [goa.group_order.ordergroup.name,
                 goa.result,
                 number_with_precision(order_article.price.fc_price * goa.result, precision: 2)]
      end

      table rows, column_widths: [200,40,40], cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
        table.columns(1..2).align = :right
        table.cells.border_width = 1
        table.cells.border_color = '666666'
      end
      move_down 10
    end
  end

end