module OrdersHelper
  def update_articles_link(order, text, view, options = {})
    options = { remote: true, id: "view_#{view}_btn", class: '' }.merge(options)
    options[:class] += ' active' if view.to_s == @view.to_s
    link_to text, order_path(order, view: view), options
  end

  # @param order [Order]
  # @param document [String] Document to display, one of +groups+, +articles+, +fax+, +matrix+
  # @param text [String] Link text
  # @param options [Hash] Options passed to +link_to+
  # @return [String] Link to order document
  # @see OrdersController#show
  def order_pdf(order, document, text, options = {})
    options = options.merge(title: I18n.t('helpers.orders.order_pdf'))
    link_to text, order_path(order, document: document, format: :pdf), options
  end

  def options_for_suppliers_to_select
    options = [[I18n.t('helpers.orders.option_choose')]]
    options += Supplier.map { |s| [s.name, url_for(action: 'new', supplier_id: s.id)] }
    options += [[I18n.t('helpers.orders.option_stock'), url_for(action: 'new', supplier_id: nil)]]
    options_for_select(options)
  end

  def format_units_to_order(order_article, strip_insignificant_zeros: false)
    format_amount(order_article.units_to_order, order_article, strip_insignificant_zeros: strip_insignificant_zeros)
  end

  # "1×2 ordered, 2×2 billed, 2×2 received"
  def units_history_line(order_article, options = {})
    if order_article.order.open?
      nil
    else
      units_info = []
      price = order_article.price
      %i[units_to_order units_billed units_received].map do |unit|
        next unless n = order_article.send(unit)

        converted_quantity = price.convert_quantity(n, price.supplier_order_unit, options[:unit].presence || price.supplier_order_unit)
        line = converted_quantity.round(3).to_s + ' '
        line += pkg_helper(price, options) + ' ' unless n == 0
        line += OrderArticle.human_attribute_name("#{unit}_short", count: converted_quantity)
        units_info << line
      end
      units_info.join(', ').html_safe
    end
  end

  def ordered_quantities_different_from_group_orders?(order_article, ordered_mark = '!', billed_mark = '?',
                                                      received_mark = '?')
    price = order_article.price
    group_orders_sum_quantity = order_article.group_orders_sum[:quantity]
    if !order_article.units_received.nil?
      if price.convert_quantity(order_article.units_received, price.supplier_order_unit,
                                price.group_order_unit).round(3) == group_orders_sum_quantity
        false
      else
        received_mark
      end
    elsif !order_article.units_billed.nil?
      order_article.units_billed == group_orders_sum_quantity ? false : billed_mark
    elsif !order_article.units_to_order.nil?
      if price.convert_quantity(order_article.units_to_order, price.supplier_order_unit,
                                price.group_order_unit).round(3) == group_orders_sum_quantity
        false
      else
        ordered_mark
      end
    end
  end

  # @param article [Article]
  # @option options [String] :icon +false+ to hide the icon
  # @option options [String] :plain +true+ to not use HTML (implies +icon+=+false+)
  # @option options [String] :soft_uq +true+ to hide unit quantity specifier on small screens.
  #   Sensible in tables with multiple columns.
  # @return [String] Text showing unit and unit quantity when applicable.
  def pkg_helper(article, options = {})
    unit_code = options[:unit] || article.supplier_order_unit
    if unit_code == article.supplier_order_unit
      first_ratio = article&.article_unit_ratios&.first
      if first_ratio.nil? || first_ratio.quantity == 1
        return "x #{article.unit}" if unit_code.nil?

        return ArticleUnitsLib.human_readable_unit(unit_code)
      end

      uq_text = "× #{number_with_precision(first_ratio.quantity, precision: 3, strip_insignificant_zeros: true)} #{ArticleUnitsLib.human_readable_unit(first_ratio.unit)}"
    else
      uq_text = ArticleUnitsLib.human_readable_unit(unit_code)
    end

    uq_text = content_tag(:span, uq_text, class: 'hidden-phone') if options[:soft_uq]
    if options[:plain]
      uq_text
    elsif options[:icon].nil? || options[:icon]
      pkg_helper_icon(uq_text)
    else
      pkg_helper_icon(uq_text, tag: :span)
    end
  end

  # @param c [Symbol, String] Tag to use
  # @option options [String] :class CSS class(es) (in addition to +package+)
  # @return [String] Icon used for displaying the unit quantity
  def pkg_helper_icon(c = nil, options = {})
    options = { tag: 'i', class: '' }.merge(options)
    if c.nil?
      c = '&nbsp;'.html_safe
      options[:class] += ' icon-only'
    end
    content_tag(options[:tag], c, class: "package #{options[:class]}").html_safe
  end

  def article_version_change_hint(order_article, gross = false)
    return nil if order_article.article_version.price == order_article.article_version.price

    title = "#{t('helpers.orders.old_price')}: #{number_to_currency order_article.article_version.price}"
    title += " / #{number_to_currency order_article.article_version.gross_price}" if gross
    content_tag(:i, nil, class: 'icon-asterisk', title: j(title)).html_safe
  end

  def receive_input_field(form)
    order_article = form.object
    price = order_article.article_version
    quantity = order_article.units_billed || order_article.units_to_order
    # units_expected = (order_article.units_billed || order_article.units_to_order) *
    #                  1.0 * order_article.article_version.unit_quantity / order_article.article_version.unit_quantity
    units_expected = price.convert_quantity(quantity, price.supplier_order_unit, price.billing_unit)

    input_classes = 'input input-nano units_received'
    input_classes += ' package' unless price.unit_quantity == 1 || price.supplier_order_unit != price.billing_unit
    data = { units_expected: units_expected, billing_unit: price.billing_unit }
    data.merge!(ratio_quantity_data(order_article, price.billing_unit))
    input_html = form.text_field :units_received, class: input_classes,
                                                  data: data,
                                                  disabled: order_article.result_manually_changed?,
                                                  autocomplete: 'off'
    span_html = if order_article.result_manually_changed?
                  content_tag(:span, class: 'input-prepend input-append intable',
                                     title: t('orders.edit_amount.field_locked_title', default: '')) do
                    button_tag(nil, type: :button, class: 'btn unlocker') {
                      content_tag(:i, nil, class: 'icon icon-unlock')
                    } + input_html
                  end
                else
                  content_tag(:span, class: 'input-append intable') { input_html }
                end

    span_html.html_safe
  end

  def ratio_quantity_data(order_article, default_unit = nil)
    data = {}
    data['supplier-order-unit'] = order_article.article_version.supplier_order_unit
    data['default-unit'] = default_unit
    data['custom-unit'] = order_article.article_version.unit
    order_article.article_version.article_unit_ratios.each_with_index do |ratio, index|
      data["ratio-quantity-#{index}"] = ratio.quantity
      data["ratio-unit-#{index}"] = ratio.unit
    end

    data
  end

  # @param order [Order]
  # @return [String] Number of ordergroups participating in order with groups in title.
  def ordergroup_count(order)
    group_orders = order.group_orders.includes(:ordergroup)
    txt = "#{group_orders.count} #{Ordergroup.model_name.human count: group_orders.count}"
    return txt if group_orders.count == 0

    desc = group_orders.includes(:ordergroup).map { |g| g.ordergroup_name }.join(', ')
    content_tag(:abbr, txt, title: desc).html_safe
  end

  # @param order_or_supplier [Order, Supplier] Order or supplier to link to
  # @return [String] Link to order or supplier, showing its name.
  def supplier_link(order_or_supplier)
    if order_or_supplier.is_a?(Order) && order_or_supplier.stockit?
      link_to(order_or_supplier.name, stock_articles_path).html_safe
    else
      link_to(@order.supplier.name, supplier_path(@order.supplier)).html_safe
    end
  end

  # @param order_article [OrderArticle]
  # @return [String] CSS class for +OrderArticle+ in table for admins (+used+, +partused+, +unused+ or +unavailable+).
  def order_article_class(order_article)
    if order_article.units > 0
      if order_article.missing_units == 0
        'used'
      else
        'partused'
      end
    elsif order_article.quantity > 0
      'unused'
    else
      'unavailable'
    end
  end

  # Button for receiving an order.
  #   If the order hasn't been received before, the button is shown in green.
  # @param order [Order]
  # @option options [String] :class Classes added to the button's class attribute.
  # @return [String] Order receive button.
  def receive_button(order, options = {})
    if order.stockit?
      content_tag :div, t('orders.index.action_receive'), class: "btn disabled #{options[:class]}"
    else
      link_to t('orders.index.action_receive'), receive_order_path(order),
              class: "btn#{' btn-success' unless order.received?} #{options[:class]}"
    end
  end

  private

  def format_amount(amount, order_article, strip_insignificant_zeros: false)
    strip_insignificant_zeros = true unless order_article.article_version.supplier_order_unit_is_si_convertible
    number_with_precision(amount, precision: 3, strip_insignificant_zeros: strip_insignificant_zeros)
  end
end
