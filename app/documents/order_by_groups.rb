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
                'Ordered', #GroupOrderArticle.human_attribute_name(:ordered),
                'Received', #GroupOrderArticle.human_attribute_name(:received),
                OrderArticle.human_attribute_name(:article),
                Article.human_attribute_name(:supplier),
                'Units @ Price', #GroupOrderArticle.human_attribute_name(:unit_price),
                GroupOrderArticle.human_attribute_name(:total_price)
              ]]

      each_group_order_article_for_ordergroup(oa_id) do |goa|
        dimrows << rows.length if goa.result == 0
        name = goa.order_article.article.name.gsub(/^\d\d\d\d:\s*/,'')
        quantity = goa.tolerance > 0 ? "#{goa.quantity}..#{goa.quantity + goa.tolerance}" : goa.quantity
        rows << [
          "#{quantity}",
          "#{goa.result}  ____  #{goa.order_article.article.unit}",
          name.truncate(30, omission: ''),
          goa.order_article.article.supplier.name.truncate(10, omission: ''),
          order_article_unit_per_price(goa.order_article),
          # goa.order_article.article.unit,
          # number_to_currency(order_article_price(goa.order_article)),
          number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1
      rows << [nil, nil, I18n.t('documents.order_by_groups.sum'), nil, nil, number_to_currency(oa_total)]

      rows.each { |row| row.delete_at 3 } unless @options[:show_supplier]

      oa = Ordergroup.find(oa_id)
      oa_phone = oa.contact_phone
      if (oa_phone.blank?)
        user_with_phone = oa.users.find { |user| !user.phone.blank? }
        oa_phone = user_with_phone.phone if (user_with_phone)
      end
      if (oa_phone.blank?)
        oa_phone = 'UPDATE PROFILE, PHONE IS REQUIRED'
      else
        # trim leading 1
        oa_phone = number_to_phone(oa_phone.sub(/^1/, ''))
      end

      oa_title = "#{oa_name}   (#{oa_phone})"
      nice_table oa_title || stock_ordergroup_name, rows, dimrows do |table|
        table.row(-2).border_width = 1
        table.row(-2).border_color = '666666'
        table.row(-1).borders = []

        if @options[:show_supplier]
          supplier_width = 60
          table.column(3).width = supplier_width
          table.column(2).width = (bounds.width / 2) - supplier_width
          table.cells.size = 11
        else
          table.cells.size = 11
          table.column(2).width = bounds.width / 2
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
