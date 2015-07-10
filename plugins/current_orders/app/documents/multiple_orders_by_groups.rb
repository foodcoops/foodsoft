# encoding: utf-8
class MultipleOrdersByGroups < OrderPdf
  include OrdersHelper

  def filename
    I18n.t('documents.multiple_orders_by_groups.filename', count: @order.count) + '.pdf'
  end

  def title
    I18n.t('documents.multiple_orders_by_groups.title', count: @order.count)
  end

  def ordergroups
    unless @ordergroups
      @ordergroups = Ordergroup.joins(:orders).where(orders: {id: @order}).select('distinct(groups.id)').select('groups.*').reorder(:name)
      @ordergroups = @ordergroups.where(id: @options[:ordergroup]) if @options[:ordergroup]
    end
    @ordergroups
  end

  # @todo refactor to reduce common code with order_by_groups
  def body
    # Start rendering
    ordergroups.each do |ordergroup|
      down_or_page 15

      total = 0
      taxes = Hash.new {0}
      rows = []
      dimrows = []
      group_order_articles = GroupOrderArticle.ordered.joins(:group_order => :order).where(:group_orders =>{:ordergroup_id => ordergroup.id}).where(:orders => {id: @order}).includes(:order_article => :article_price).reorder('orders.id')
      has_tolerance = group_order_articles.where('article_prices.unit_quantity > 1').any?

      group_order_articles.each do |goa|
        price = goa.order_article.price.fc_price
        sub_total = goa.total_price
        total += sub_total
        rows <<  [goa.order_article.article.name,
                  goa.group_order.order.name.truncate(10, omission: ''),
                  number_to_currency(price),
                  goa.order_article.article.unit,
                  goa.tolerance > 0 ? "#{goa.quantity} + #{goa.tolerance}" : goa.quantity,
                  goa.result,
                  number_to_currency(sub_total),
                  (goa.order_article.price.unit_quantity if has_tolerance)]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0

      # total
      rows << [{content: I18n.t('documents.order_by_groups.sum'), colspan: 6}, number_to_currency(total), nil]

      # table header
      rows.unshift [
        OrderArticle.human_attribute_name(:article),
        Article.human_attribute_name(:supplier),
        I18n.t('documents.order_by_groups.rows')[3],
        Article.human_attribute_name(:unit),
        I18n.t('shared.articles.ordered'),
        I18n.t('shared.articles.received'),
        I18n.t('shared.articles_by.price_sum'),
        has_tolerance ? {image: "#{Rails.root}/app/assets/images/package-bg.png", scale: 0.6, position: :center} : nil
      ]

      text ordergroup.name, size: fontsize(13), style: :bold
      table rows, width: bounds.width, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
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

        table.column(0).width = 180 # @todo would like to set minimum width here
        table.column(1).width = 62
        table.column(2).align = :right
        table.column(5..6).font_style = :bold
        table.columns(3..5).align = :center
        table.column(6).align = :right
        table.column(7).align = :center
        # dim rows not relevant for members
        table.column(4).text_color = '999999'
        table.column(7).text_color = '999999'
        # hide unit_quantity if there's no tolerance anyway
        table.column(-1).width = has_tolerance ? 20 : 0

        # dim rows which were ordered but not received
        dimrows.each do |ri|
          table.row(ri).text_color = 'aaaaaa'
          table.row(ri).columns(0..-1).font_style = nil
        end
      end
    end
  end

  protected

  def pdf_add_page_breaks?
    super 'order_by_groups'
  end

end
