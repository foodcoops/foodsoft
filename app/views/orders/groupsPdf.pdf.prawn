end_date = @order.ends.strftime('%d.%m.%Y')
title = "Gruppensortierung für #{@order.name}, beendet am #{end_date}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+20] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end


# Start rendering
groups = @order.group_order_results.size
counter = 1
for group_result in @order.group_order_results
  pdf.text group_result.group_name, :style => :bold
  pdf.move_down 5
  pdf.text "Gruppe #{counter.to_s}/#{groups.to_s}", :size => 8
  pdf.move_down 5

  total = 0
  data = []
  group_result.group_order_article_results.each do |result|
    price = result.order_article_result.gross_price
    quantity = result.quantity
    sub_total = price * quantity
    total += sub_total
    data <<  [result.order_article_result.name,
              quantity, price,
              result.order_article_result.unit_quantity,
              result.order_article_result.unit,
              sub_total]
  end
  data << [ {:text => "Summe", :colspan => 5}, total]

  pdf.table data,
    :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => ["Artikel", "Menge", "Preis", "GebGr", "Einheit", "Summe"],
    :widths => { 0 => 250 },
    :row_colors => ['ffffff','ececec']

  counter += 1
  pdf.move_down 10
end