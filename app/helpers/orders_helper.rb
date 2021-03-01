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
    options += Supplier.map { |s| [s.name, url_for(action: "new", supplier_id: s.id)] }
    options += [[I18n.t('helpers.orders.option_stock'), url_for(action: 'new', supplier_id: nil)]]
    options_for_select(options)
  end

  # "1×2 ordered, 2×2 billed, 2×2 received"
  def units_history_line(order_article, options = {})
    if order_article.order.open?
      nil
    else
      units_info = []
      [:units_to_order, :units_billed, :units_received].map do |unit|
        if n = order_article.send(unit)
          line = n.to_s + ' '
          line += pkg_helper(order_article.price, options) + ' ' unless n == 0
          line += OrderArticle.human_attribute_name("#{unit}_short", count: n)
          units_info << line
        end
      end
      units_info.join(', ').html_safe
    end
  end

  # @param article [Article]
  # @option options [String] :icon +false+ to hide the icon
  # @option options [String] :plain +true+ to not use HTML (implies +icon+=+false+)
  # @option options [String] :soft_uq +true+ to hide unit quantity specifier on small screens.
  #   Sensible in tables with multiple columns.
  # @return [String] Text showing unit and unit quantity when applicable.
  def pkg_helper(article, options = {})
    return '' if !article || article.unit_quantity == 1

    uq_text = "× #{article.unit_quantity}"
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
      c = "&nbsp;".html_safe
      options[:class] += " icon-only"
    end
    content_tag(options[:tag], c, class: "package #{options[:class]}").html_safe
  end

  def article_price_change_hint(order_article, gross = false)
    return nil if order_article.article.price == order_article.price.price

    title = "#{t('helpers.orders.old_price')}: #{number_to_currency order_article.article.price}"
    title += " / #{number_to_currency order_article.article.gross_price}" if gross
    content_tag(:i, nil, class: 'icon-asterisk', title: j(title)).html_safe
  end

  def receive_input_field(form)
    order_article = form.object
    units_expected = (order_article.units_billed || order_article.units_to_order) *
                     1.0 * order_article.article.unit_quantity / order_article.article_price.unit_quantity

    input_classes = 'input input-nano units_received'
    input_classes += ' package' unless order_article.article_price.unit_quantity == 1
    input_html = form.text_field :units_received, class: input_classes,
                                                  data: { 'units-expected' => units_expected },
                                                  disabled: order_article.result_manually_changed?,
                                                  autocomplete: 'off'

    if order_article.result_manually_changed?
      input_html = content_tag(:span, class: 'input-prepend intable', title: t('orders.edit_amount.field_locked_title', default: '')) {
        button_tag(nil, type: :button, class: 'btn unlocker') {
          content_tag(:i, nil, class: 'icon icon-unlock')
        } + input_html
      }
    end

    input_html.html_safe
  end

  # @param order [Order]
  # @return [String] Number of ordergroups participating in order with groups in title.
  def ordergroup_count(order)
    group_orders = order.group_orders.includes(:ordergroup)
    txt = "#{group_orders.count} #{Ordergroup.model_name.human count: group_orders.count}"
    if group_orders.count == 0
      return txt
    else
      desc = group_orders.includes(:ordergroup).map { |g| g.ordergroup_name }.join(', ')
      content_tag(:abbr, txt, title: desc).html_safe
    end
  end

  # @param order_or_supplier [Order, Supplier] Order or supplier to link to
  # @return [String] Link to order or supplier, showing its name.
  def supplier_link(order_or_supplier)
    if order_or_supplier.kind_of?(Order) && order_or_supplier.stockit?
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
      link_to t('orders.index.action_receive'), receive_order_path(order), class: "btn#{' btn-success' unless order.received?} #{options[:class]}"
    end
  end
end
