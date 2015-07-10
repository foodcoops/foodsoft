# encoding: utf-8
class OrderByGroups < OrderPdf

  def filename
    I18n.t('documents.order_by_groups.filename', :name => @order.name, :date => @order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_groups.title', :name => @order.name,
      :date => @order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    # Start rendering
    @order.group_orders.ordered.each do |group_order|
      down_or_page 15

      total = 0
      rows = []
      dimrows = []

      group_order_articles = group_order.group_order_articles.ordered
      group_order_articles.each do |goa|
        price = goa.order_article.price.fc_price
        sub_total = price * goa.result
        total += sub_total
        rows <<  [goa.order_article.article.name,
                  goa.tolerance > 0 ? "#{goa.quantity} + #{goa.tolerance}" : goa.quantity,
                  goa.result,
                  number_to_currency(price),
                  goa.order_article.price.unit_quantity,
                  goa.order_article.article.unit,
                  number_to_currency(sub_total)]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      rows << [ I18n.t('documents.order_by_groups.sum'), nil, nil, nil, nil, nil, number_to_currency(total)]
      rows.unshift I18n.t('documents.order_by_groups.rows') # Table Header

      text group_order.ordergroup.name, size: fontsize(9), style: :bold
      table rows, width: 500, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
        # borders
        table.cells.borders = [:bottom]
        table.cells.border_width = 0.02
        table.cells.border_color = 'dddddd'
        table.rows(0).border_width = 1
        table.rows(0).border_color = '666666'
        table.rows(0).column(5).font_style = :bold
        table.row(rows.length-2).border_width = 1
        table.row(rows.length-2).border_color = '666666'
        table.row(rows.length-1).borders = []

        table.column(0).width = 240
        table.column(2).font_style = :bold
        table.columns(1..4).align = :right
        table.column(6).align = :right
        table.column(6).font_style = :bold

        # dim rows which were ordered but not received
        dimrows.each do |ri|
          table.row(ri).text_color = '999999'
          table.row(ri).columns(0..-1).font_style = nil
        end
      end
    end

  end
end
