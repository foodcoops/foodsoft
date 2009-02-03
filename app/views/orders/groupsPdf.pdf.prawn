end_date = @order.ends.strftime('%d.%m.%Y')
title = "Gruppensortierung für #{@order.supplier.name}, beendet am #{end_date}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+20] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end


# Start rendering
groups = @order.group_orders.size
counter = 1
for group_order in @order.group_orders
  pdf.text group_order.ordergroup.name, :style => :bold
  pdf.move_down 5
  pdf.text "Gruppe #{counter.to_s}/#{groups.to_s}", :size => 8
  pdf.move_down 5

  total = 0
  data = []
  group_order.group_order_articles.ordered.each do |goa|
    price = goa.order_article.price.fc_price
    quantity = goa.quantity
    sub_total = price * quantity
    total += sub_total
    data <<  [goa.order_article.article.name,
              quantity, number_with_precision(price),
              goa.order_article.price.unit_quantity,
              goa.order_article.article.unit,
              number_with_precision(sub_total)]
  end
  data << [ {:text => "Summe", :colspan => 5}, number_with_precision(total)]

  pdf.table data,
    :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => ["Artikel", "Menge", "Preis", "GebGr", "Einheit", "Summe"],
    :widths => { 0 => 250 },
    :row_colors => ['ffffff','ececec'],
    :align => { 0 => :right, 5 => :right }

  counter += 1
  pdf.move_down 10
end