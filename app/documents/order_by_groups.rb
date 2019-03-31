# encoding: utf-8
class OrderByGroups < OrderPdf

  def filename
    I18n.t('documents.order_by_groups.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_groups.title', :name => order.name,
           :date => order.ends.strftime(I18n.t('date.formats.default')),
           :user_name => @order.created_by.name)
  end

  def body
    each_ordergroup do |oa_name, oa_total, oa_id|
      dimrows = []
      rows = [[
        GroupOrderArticle.human_attribute_name(:ordered),
        GroupOrderArticle.human_attribute_name(:received),
        GroupOrderArticle.human_attribute_name(:unit_price),
        Article.human_attribute_name(:supplier),
        OrderArticle.human_attribute_name(:article),
        GroupOrderArticle.human_attribute_name(:total_price)
      ]]

      each_group_order_article_for_ordergroup(oa_id) do |goa|
        dimrows << rows.length if goa.result == 0
        rows << [
            goa.tolerance > 0 ? "#{goa.quantity} (+#{goa.tolerance} extra)" : goa.quantity,
            "#{goa.result}    ____ ",
            order_article_unit_per_price(goa.order_article),
            # goa.order_article.article.unit,
            # number_to_currency(order_article_price(goa.order_article)),
            goa.order_article.article.supplier.name.truncate(10, omission: ''),
            goa.order_article.article.name,
            number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1
      rows << [nil, nil, nil, nil, I18n.t('documents.order_by_groups.sum'), number_to_currency(oa_total)]

      rows.each { |row| row.delete_at 3 } unless @options[:show_supplier]

      nice_table oa_name || stock_ordergroup_name, rows, dimrows do |table|
        table.row(-2).border_width = 1
        table.row(-2).border_color = '666666'
        table.row(-1).borders = []

        if @options[:show_supplier]
          supplier_width = 60
          table.column(3).width = supplier_width
          table.column(4).width = (bounds.width / 2) - supplier_width
        else
          table.column(3).width = bounds.width / 2
        end

        # table.columns(-4..-1).align = :right
        # table.column(-3).font_style = :bold
        # table.column(-1).font_style = :bold

        # table.column(4).width = 80
        # table.column(2).font_style = :bold
        # table.columns(1..2).align = :left
        # table.column(3).align = :right
        # table.column(4).align = :left
        # table.column(6).align = :right
        # table.column(2).font_style = :bold
        # table.column(5).width = 1
      end
    end
  end

end
