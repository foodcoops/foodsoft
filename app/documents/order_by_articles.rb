class OrderByArticles < OrderPdf
  def filename
    I18n.t('documents.order_by_articles.filename', name: order.name, date: order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', name: order.name,
                                                date: order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    each_order_article do |order_article|
      article_version = order_article.article_version
      dimrows = []
      rows = [[
        GroupOrder.human_attribute_name(:ordergroup),
        GroupOrderArticle.human_attribute_name(:ordered),
        GroupOrderArticle.human_attribute_name(:received),
        GroupOrderArticle.human_attribute_name(:total_price)
      ]]

      each_group_order_article_for_order_article(order_article) do |goa|
        dimrows << rows.length if goa.result == 0
        rows << [goa.group_order.ordergroup_name,
                 billing_quantity_with_tolerance(goa),
                 number_with_precision(article_version.convert_quantity(goa.result, article_version.group_order_unit,
                                                  article_version.billing_unit)),
                 number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1

      name = "#{article_version.name}, #{format_billing_unit_with_ratios(article_version)}, #{number_to_currency(article_version.convert_quantity(
                                                                                                                   article_version.fc_price, article_version.billing_unit, article_version.supplier_order_unit
                                                                                                                 ))}"
      name += " #{order_article.order.name}" if @options[:show_supplier]
      nice_table name, rows, dimrows do |table|
        table.column(0).width = bounds.width / 2
        table.columns(1..-1).align = :right
        table.column(2).font_style = :bold
      end
    end
  end
end
