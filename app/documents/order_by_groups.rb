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
    @order.group_orders.each do |group_order|
      text group_order.ordergroup.name, size: 9, style: :bold

      total = 0
      rows = []
      rows << I18n.t('documents.order_by_groups.rows') # Table Header

      group_order_articles = group_order.group_order_articles.ordered
      group_order_articles.each do |goa|
        price = goa.order_article.price.fc_price
        sub_total = price * goa.result
        total += sub_total
        rows <<  [goa.order_article.article.name,
                  goa.result,
                  number_with_precision(price, precision: 2),
                  goa.order_article.price.unit_quantity,
                  goa.order_article.article.unit,
                  number_with_precision(sub_total, precision: 2)]
      end
      rows << [ I18n.t('documents.order_by_groups.sum'), nil, nil, nil, nil, number_with_precision(total, precision: 2)]

      table rows, column_widths: [250,50,50,50,50,50], cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
        # borders
        table.cells.borders = []
        table.row(0).borders = [:bottom]
        table.row(group_order_articles.size).borders = [:bottom]
        table.cells.border_width            = 1
        table.cells.border_color            = '666666'

        table.columns(1..3).align = :right
        table.columns(5).align = :right
      end

      move_down 15
    end

  end
end
