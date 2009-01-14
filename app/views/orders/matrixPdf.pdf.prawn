title = "#{@order.name}, beendet am #{@order.ends.strftime('%d.%m.%Y')}"

# Define header and footer
pdf.header [pdf.margin_box.left,pdf.margin_box.top+20] do
  pdf.text title, :size => 10, :align => :center
end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end

max_articles_per_page = 17 # How many articles shoud written on a page
articles = @order.order_article_results

pdf.text "Artikelübersicht", :style => :bold
pdf.move_down 5
pdf.text "Insgesamt #{articles.size} Artikel", :size => 8
pdf.move_down 10

articles_data = articles.collect do |a|
  [a.name, a.unit, a.unit_quantity, a.gross_price, a.units_to_order]
end
pdf.table articles_data,
  :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => ["Artikel", "Einheit", "Gebinde", "Preis", "Menge"]


page_number = 0
total_num_articles = articles.size

while (page_number * max_articles_per_page < total_num_articles) do  # Start page generating

  page_number += 1
  pdf.start_new_page(:layout => :landscape)

  # Collect articles for this page
  current_articles = articles.select do |a|
    articles.index(a) >= (page_number-1) * max_articles_per_page and
    articles.index(a) < page_number * max_articles_per_page
  end

  # Make articles header
  header = [""]
  for header_article in current_articles
    name = header_article.name.split("-").join(" ").split(".").join(". ").split("/").join(" ")
    name = name.split.collect { |w| truncate(w, 8, "..") }.join(" ")
    header << truncate(name, 30, " ..")
  end

  # Collect group results
  groups_data = []
  for group_order_result in @order.group_order_results

    group_result = [truncate(group_order_result.group_name, 20)]

    for article in current_articles
      # get the OrdergroupResult for this article
      result = GroupOrderArticleResult.find(:first,
        :conditions => ['order_article_result_id = ? AND group_order_result_id = ?', article.id, group_order_result.id])
      group_result << ((result.nil? || result == 0) ? "" : result.quantity.to_i)
    end
    groups_data << group_result
  end

  # Make table
  widths = { }
  (max_articles_per_page + 1).times { |i| widths.merge!({ i => 40 }) unless i == 0 }
  pdf.table groups_data,
    :font_size => 8,
    :border_style => :grid,
    :vertical_padding => 3,
    :headers => header,
    :widths => widths,
    :row_colors => ['ffffff','ececec']

end