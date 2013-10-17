# encoding: utf-8
class MultipleOrdersByGroups < OrderPdf

  def filename
    I18n.t('documents.order_by_groups.multiple.filename', count: @order.count) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_groups.multiple.title', count: @order.count)
  end

  def body
    # Start rendering
    Ordergroup.joins(:orders).where(:orders => {:id => @order}).select('distinct(groups.id) AS id, groups.name AS name').order('name').each do |ordergroup|

      total = 0
      rows = []
      dimrows = []

      GroupOrderArticle.ordered.joins(:group_order => :order).where(:group_orders =>{:ordergroup_id => ordergroup.id}).where(:orders => {id: @order}).includes(:order_article).order(:order => :id).each do |goa|
        price = goa.order_article.price.fc_price
        sub_total = price * goa.result
        total += sub_total
        rows <<  [goa.order_article.article.name,
                  goa.group_order.order.name.truncate(10, omission: ''),
                  "#{goa.quantity} + #{goa.tolerance}",
                  goa.result,
                  number_with_precision(price, precision: 2),
                  goa.order_article.price.unit_quantity,
                  goa.order_article.article.unit,
                  number_with_precision(sub_total, precision: 2)]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      rows << [I18n.t('documents.order_by_groups.sum'), nil, nil, nil, nil, nil, nil, number_with_precision(total, precision: 2)]
      rows.unshift I18n.t('documents.order_by_groups.rows').dup.insert(1, Order.model_name.human) # Table Header

      text ordergroup.name, size: 9, style: :bold
      table rows, width: 500, cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
        # borders
        table.cells.borders = []
        table.row(0).borders = [:bottom]
        table.row(rows.length-2).borders = [:bottom]
        table.cells.border_width            = 1
        table.cells.border_color            = '666666'

        table.column(0).width = 190
        table.column(1).width = 50
        table.column(3).font_style = :bold
        table.columns(2..5).align = :right
        table.column(7).align = :right
        table.column(7).font_style = :bold

        # dim rows which were ordered but not received
        dimrows.each { |ri| table.row(ri).text_color = '999999' }
      end

      move_down 15
    end

  end
end
