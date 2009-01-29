end_date = @order.ends.strftime('%d.%m.%Y')
title = "#{@order.supplier.name} | beendet am #{end_date}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+30] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end

# Start rendering

for order_article in @order.order_articles.ordered
  pdf.text "#{order_article.article.name} (#{order_article.article.unit} |\
#{order_article.price.unit_quantity.to_s} | #{number_to_currency(order_article.price.fc_price)})",
    :style => :bold, :size => 10
  pdf.move_down 5
  data = []
  for goa in order_article.group_order_articles
    data << [goa.group_order.ordergroup.name,
            goa.quantity,
            number_with_precision(order_article.price.fc_price * goa.quantity)]
  end

  pdf.table data,
    :font_size => 8,
    :headers => ["Bestellgruppe", "Menge", "Preis"],
    :widths => { 0 => 200, 1 => 40, 2 => 40 },
    :border_style => :grid,
    :row_colors => ['ffffff','ececec'],
    :vertical_padding => 3,
    :align => { 2 => :right }
  pdf.move_down 10
end
