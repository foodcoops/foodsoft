class OrderPdf < RenderPDF
  attr_reader :order

  def initialize(order, options = {})
    @order = order
    @orders = order
    super(options)
  end

  def nice_table(name, data, dimrows = [])
    name_options = { size: 10, style: :bold }
    name_height = height_of name, name_options
    made_table = make_table data, width: bounds.width, cell_style: { size: 8, overflow: :shrink_to_fit } do |table|
      # borders
      table.cells.borders = [:bottom]
      table.cells.padding_top = 2
      table.cells.padding_bottom = 4
      table.cells.border_color = 'dddddd'
      table.rows(0).border_color = '666666'

      # dim rows which were ordered but not received
      dimrows.each do |ri|
        table.row(ri).text_color = '999999'
        table.row(ri).columns(0..-1).font_style = nil
      end

      yield table if block_given?
    end

    if name_height + made_table.height < cursor
      down_or_page 15
    else
      start_new_page
    end

    text name, name_options
    made_table.draw
  end

  protected

  # Return price for order_article.
  #
  # This is a separate method so that plugins can override it.
  #
  # @param article [OrderArticle]
  # @return [Number] Price to show
  # @see https://github.com/foodcoops/foodsoft/issues/445
  def order_article_price(order_article)
    order_article.price.fc_price
  end

  def order_article_price_per_unit(order_article)
    "#{number_to_currency(order_article_price(order_article))} / #{order_article.article.unit}"
  end

  def group_order_article_quantity_with_tolerance(goa)
    goa.tolerance > 0 ? "#{goa.quantity} + #{goa.tolerance}" : "#{goa.quantity}"
  end

  def group_order_article_result(goa)
    number_with_precision goa.result, strip_insignificant_zeros: true
  end

  def group_order_articles(ordergroup)
    GroupOrderArticle
      .includes(:group_order)
      .where(group_orders: { order_id: @orders, ordergroup_id: ordergroup })
  end

  def order_articles
    OrderArticle
      .ordered
      .includes(article: :supplier)
      .includes(group_order_articles: { group_order: :ordergroup })
      .where(order: @orders)
      .order('suppliers.name, articles.name, groups.name')
      .preload(:article_price)
  end

  def ordergroups(offset = nil, limit = nil)
    result = GroupOrder
             .ordered
             .where(order: @orders)
             .group('groups.id')
             .offset(offset)
             .limit(limit)
             .pluck('groups.name', 'SUM(group_orders.price)', 'ordergroup_id', 'SUM(group_orders.transport)')

    result.map do |item|
      [item.first || stock_ordergroup_name] + item[1..-1]
    end
  end

  def each_order_article(&block)
    order_articles.each(&block)
  end

  def each_ordergroup(&block)
    ordergroups.each(&block)
  end

  def each_ordergroup_batch(batch_size)
    offset = 0

    while true
      go_records = ordergroups(offset, batch_size)

      break unless go_records.any?

      group_ids = go_records.map(&:third)

      # get quantity for each article and ordergroup
      goa_records = group_order_articles(group_ids)
                    .group('group_order_articles.order_article_id, group_orders.ordergroup_id')
                    .pluck('group_order_articles.order_article_id', 'group_orders.ordergroup_id', 'SUM(COALESCE(group_order_articles.result, group_order_articles.quantity))')

      # transform the flat list of results in a hash (with the article as key), which contains an array for all ordergroups
      results = goa_records.group_by(&:first).transform_values do |value|
        grouped_value = value.group_by(&:second)
        group_ids.map do |group_id|
          number_with_precision grouped_value[group_id].try(:first).try(:third), strip_insignificant_zeros: true
        end
      end

      yield go_records, results
      offset += batch_size
    end
  end

  def each_group_order_article_for_order_article(order_article, &block)
    order_article.group_order_articles.each(&block)
  end

  def each_group_order_article_for_ordergroup(ordergroup, &block)
    group_order_articles(ordergroup)
      .includes(order_article: { article: [:supplier] })
      .order('suppliers.name, articles.name')
      .preload(order_article: [:article_price, :order])
      .each(&block)
  end

  def stock_ordergroup_name
    users = GroupOrder.stock
                      .eager_load(:updated_by)
                      .where(order: @orders)
                      .map(&:updated_by)
                      .map { |u| u.try(&:name) || '?' }

    I18n.t('model.group_order.stock_ordergroup_name', user: users.uniq.sort.join(', '))
  end
end
