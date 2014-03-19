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
      total = 0
      rows = []
      dimrows = []

      group_order_articles = group_order.group_order_articles.ordered
      group_order_articles.each do |goa|
        price = goa.order_article.price.fc_price
        sub_total = price * goa.result
        total += sub_total
        rows <<  [goa.order_article.article.name,
                  "#{goa.quantity} + #{goa.tolerance}",
                  goa.result,
                  number_with_precision(price, precision: 2),
                  goa.order_article.price.unit_quantity,
                  goa.order_article.article.unit,
                  number_with_precision(sub_total, precision: 2)]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      rows << [ I18n.t('documents.order_by_groups.sum'), nil, nil, nil, nil, nil, number_with_precision(total, precision: 2)]
      rows.unshift I18n.t('documents.order_by_groups.rows') # Table Header

      text group_order.ordergroup.name, size: fontsize(9), style: :bold
      table rows, width: 500, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
        # borders
        table.cells.borders = []
        table.row(0).borders = [:bottom]
        table.row(group_order_articles.size).borders = [:bottom]
        table.cells.border_width            = 1
        table.cells.border_color            = '666666'

        table.column(0).width = 240
        table.column(2).font_style = :bold
        table.columns(1..4).align = :right
        table.column(6).align = :right
        table.column(6).font_style = :bold

        # dim rows which were ordered but not received
        dimrows.each { |ri| table.row(ri).text_color = '999999' }
      end

      down_or_page 15
    end

  end
end
