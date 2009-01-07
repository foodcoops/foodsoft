# Get ActiveRecord objects
order_articles = @order.order_article_results
end_date = @order.ends.strftime('%d.%m.%Y')
title = "#{@order.name} | beendet am #{end_date}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+30] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end

# Start rendering
pdf.table [["Bestellgruppe", "Menge", "Preis"]],
  :font_size => 8,
  :font_style => :italic,
  :widths => { 0 => 200, 1 => 40, 2 => 40 }
pdf.move_down 10

for article in order_articles
  pdf.text "#{article.name} (#{article.unit} | #{article.unit_quantity.to_s} | #{number_to_currency(article.gross_price)})",
    :style => :bold, :size => 10
  pdf.move_down 5
  data = []
  for result in article.group_order_article_results
    data << [result.group_order_result.group_name,
            result.quantity,
            article.gross_price * result.quantity]
  end

  pdf.table data,
    :font_size => 8,
    :widths => { 0 => 200, 1 => 40, 2 => 40 },
    :border_style => :grid
  pdf.move_down 10
end
