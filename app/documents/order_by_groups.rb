class OrderByGroups < OrderPdf
  def filename
    I18n.t('documents.order_by_groups.filename', name: order.name, date: order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_groups.title', name: order.name,
                                              date: order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    each_ordergroup do |oa_name, oa_total, oa_id, oa_transport|
      has_transport = !oa_transport.nil? && oa_transport > 0
      dimrows = []
      rows = [[
        OrderArticle.human_attribute_name(:article),
        Article.human_attribute_name(:supplier),
        GroupOrderArticle.human_attribute_name(:ordered),
        GroupOrderArticle.human_attribute_name(:received),
        GroupOrderArticle.human_attribute_name(:unit_price),
        GroupOrderArticle.human_attribute_name(:total_price)
      ]]

      each_group_order_article_for_ordergroup(oa_id) do |goa|
        dimrows << rows.length if goa.result == 0
        rows << [goa.order_article.article_version.name,
                 goa.group_order.order.name,
                 billing_quantity_with_tolerance(goa),
                 billing_article_result(goa),
                 price_per_billing_unit(goa),
                 number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1

      rows << [nil, nil, nil, nil, nil, number_to_currency(oa_total)]
      if has_transport
        rows << [GroupOrder.human_attribute_name(:transport), nil, nil, nil, nil, number_to_currency(oa_transport)]
        rows << [nil, nil, nil, nil, nil, number_to_currency(oa_total + oa_transport)]
      end

      rows.each { |row| row.delete_at 1 } unless @options[:show_supplier]

      nice_table oa_name || stock_ordergroup_name, rows, dimrows do |table|
        if has_transport
          table.row(-4).border_width = 1
          table.row(-4).border_color = '666666'
        end

        table.row(-2).border_width = 1
        table.row(-2).border_color = '666666'
        table.row(-1).borders = []

        if @options[:show_supplier]
          table.column(0).width = bounds.width / 3
          table.column(1).width = bounds.width / 4
        else
          table.column(0).width = bounds.width / 2
        end

        table.columns(-4..-1).align = :right
        table.column(-3).font_style = :bold
        table.column(-1).font_style = :bold
      end
    end
  end
end
