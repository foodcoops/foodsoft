# encoding: utf-8
class MultipleOrdersByArticles < OrderPdf
  include OrdersHelper

  def filename
    I18n.t('documents.multiple_orders_by_articles.filename', count: @order.count) + '.pdf'
  end

  def title
    I18n.t('documents.multiple_orders_by_articles.title', count: @order.count)
  end

  def order_articles
    @order_articles ||= OrderArticle.joins(:order, :article).where(:orders => {:id => @order}).ordered.reorder('orders.id, articles.name')
  end

  # @todo refactor to reduce common code with order_by_articles
  def body
    order_articles.each do |order_article|
      down_or_page

      rows = []
      dimrows = []
      has_units_str = ''
      for goa in order_article.group_order_articles.ordered
        rows << [goa.group_order.ordergroup.name,
                 goa.tolerance > 0 ? "#{goa.quantity} + #{goa.tolerance}" : goa.quantity,
                 goa.result,
                 number_to_currency(goa.total_price(order_article))]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      sum = order_article.group_orders_sum
      rows.unshift I18n.t('documents.order_by_articles.rows').dup # table header

      rows << [I18n.t('documents.order_by_groups.sum'),
               order_article.tolerance > 0 ? "#{order_article.quantity} + #{order_article.tolerance}" : order_article.quantity,
               sum[:quantity],
               nil] #number_to_currency(sum[:price])]

      text "<b>#{order_article.article.name}</b> " +
           "(#{order_article.article.unit}; #{number_to_currency order_article.price.fc_price}; " +
           units_history_line(order_article, plain: true) + ')',
           size: fontsize(10), inline_format: true
      table rows, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
        # borders
        table.cells.borders = [:bottom]
        table.cells.border_width = 0.02
        table.cells.border_color = 'dddddd'
        table.rows(0).border_width = 1
        table.rows(0).border_color = '666666'
        table.row(rows.length-2).border_width = 1
        table.row(rows.length-2).border_color = '666666'
        table.row(rows.length-1).borders = []

        table.column(0).width = 200
        table.columns(1..2).align = :center
        table.column(2).font_style = :bold
        table.columns(3).align = :right

        # dim rows which were ordered but not received
        dimrows.each { |ri| table.row(ri).text_color = '999999' }
      end
    end
  end

  protected

  def pdf_add_page_breaks?
    super 'order_by_articles'
  end

end
