title = "#{@order.name}, beendet am #{@order.ends.strftime('%d.%m.%Y')}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+20] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.move_down 2
  pdf.text "Seite #{pdf.page_count}", :size => 8
end

max_order_articles_per_page = 16 # How many order_articles shoud written on a page
order_articles = @order.order_articles.ordered

pdf.text "Artikelübersicht", :style => :bold
pdf.move_down 5
pdf.text "Insgesamt #{order_articles.size} Artikel", :size => 8
pdf.move_down 10

order_articles_data = order_articles.collect do |a|
  [a.article.name, a.article.unit, a.price.unit_quantity, number_with_precision(a.price.fc_price), a.units_to_order]
end
pdf.table order_articles_data,
  :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => ["Artikel", "Einheit", "Gebinde", "FC-Preis", "Menge"],
    :align => { 3 => :right }


page_number = 0
total_num_order_articles = order_articles.size

while (page_number * max_order_articles_per_page < total_num_order_articles) do  # Start page generating

  page_number += 1
  pdf.start_new_page(:layout => :landscape)
  pdf.header [pdf.margin_box.left,pdf.margin_box.top+20] do
    pdf.text title, :size => 10, :align => :center
  end

  # Collect order_articles for this page
  current_order_articles = order_articles.select do |a|
    order_articles.index(a) >= (page_number-1) * max_order_articles_per_page and
    order_articles.index(a) < page_number * max_order_articles_per_page
  end

  # Make order_articles header
  header = [""]
  for header_article in current_order_articles
    name = header_article.article.name.gsub(/[-\/]/, " ").gsub(".", ". ")
    name = name.split.collect { |w| truncate(w, :length => 8, :omission => "..") }.join(" ")
    header << truncate(name, :length => 30, :omission => " ..")
  end

  # Collect group results
  groups_data = []
  for group_order in @order.group_orders.all(:include => :ordergroup)

    group_result = [truncate(group_order.ordergroup.name, :length => 20)]

    for order_article in current_order_articles
      # get the Ordergroup result for this order_article
      goa = order_article.group_order_articles.first :conditions => { :group_order_id => group_order.id }
      group_result << ((goa.nil? || goa.result == 0) ? "" : goa.result.to_i)
    end
    groups_data << group_result
  end

  # Make table
  widths = {0 => 85}  # Generate widths-hash for table layout
  (max_order_articles_per_page + 1).times { |i| widths.merge!({ i => 41 }) unless i == 0 }
  logger.debug "Spaltenbreiten: #{widths.inspect}"
  pdf.table groups_data,
    :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => header,
    :column_widths => widths,
    :row_colors => ['ffffff','ececec']

end