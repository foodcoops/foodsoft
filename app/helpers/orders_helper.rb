# encoding: utf-8
module OrdersHelper

  def update_articles_link(order, text, view, options={})
    options = {remote: true, id: "view_#{view}_btn", class: ''}.merge(options)
    options[:class] += ' active' if view.to_s == @view.to_s
    link_to text, order_path(order, view: view), options
  end

  def order_pdf(order, document, text)
    link_to text, order_path(order, document: document, format: :pdf), title: I18n.t('helpers.orders.order_pdf')
  end

  def options_for_suppliers_to_select
    options = [[I18n.t('helpers.orders.option_choose')]]
    options += Supplier.all.map {|s| [ s.name, url_for(action: "new", supplier_id: s)] }
    options += [[I18n.t('helpers.orders.option_stock'), url_for(action: 'new', supplier_id: 0)]]
    options_for_select(options)
  end

  # "1 ordered units, 2 billed, 2 received"
  def units_history_line(order_article, options={})
    if order_article.order.open?
      nil
    else
      units_info = ''
      [:units_to_order, :units_billed, :units_received].map do |unit|
        if n = order_article.send(unit)
          i18nkey = if units_info.blank? and options[:plain] then unit else "#{unit}_short" end
          units_info += n.to_s + ' '
          units_info += pkg_helper(order_article.price) + ' ' unless options[:plain] or n == 0
          units_info += OrderArticle.human_attribute_name(i18nkey, count: n)
        end
      end
      units_info.html_safe
    end
  end

  # can be article or article_price
  #   icon: `false` to not show the icon
  #   soft_uq: `true` to hide unit quantity specifier on small screens
  #            sensible in tables with multiple columns calling `pkg_helper`
  def pkg_helper(article, options={})
    return nil if not article or article.unit_quantity == 1
    uq_text = "&times; #{article.unit_quantity}".html_safe
    uq_text = content_tag(:span, uq_text, class: 'hidden-phone') if options[:soft_uq]
    if options[:icon].nil? or options[:icon]
      pkg_helper_icon(uq_text)
    else
      pkg_helper_icon(uq_text, tag: :span)
    end
  end
  def pkg_helper_icon(c=nil, options={})
    options = {tag: 'i', class: ''}.merge(options)
    if c.nil?
      c = "&nbsp;".html_safe
      options[:class] += " icon-only"
    end
    content_tag(options[:tag], c, class: "package #{options[:class]}").html_safe
  end
  
  def article_price_change_hint(order_article, gross=false)
    return nil if order_article.article.price == order_article.price.price
    title = "#{t('helpers.orders.old_price')}: #{number_to_currency order_article.article.price}"
    title += " / #{number_to_currency order_article.article.gross_price}" if gross
    content_tag(:i, nil, class: 'icon-asterisk', title: j(title)).html_safe
  end
  
  def receive_input_field(form)
    order_article = form.object
    units_expected = (order_article.units_billed or order_article.units_to_order) *
      1.0 * order_article.article.unit_quantity / order_article.article_price.unit_quantity
    
    input_classes = 'input input-nano units_received'
    input_classes += ' package' unless order_article.article_price.unit_quantity == 1
    input_html = form.text_field :units_received, class: input_classes,
      data: {'units-expected' => units_expected},
      disabled: order_article.result_manually_changed?,
      autocomplete: 'off'
    
    if order_article.result_manually_changed?
      input_html = content_tag(:span, class: 'input-prepend intable', title: t('.field_locked_title', default: '')) {
        button_tag(nil, type: :button, class: 'btn unlocker') {
          content_tag(:i, nil, class: 'icon icon-unlock')
        } + input_html
      }
    end

    input_html.html_safe
  end

  def ordergroup_count(order)
    group_orders = order.group_orders.includes(:ordergroup)
    txt = "#{group_orders.count} #{Ordergroup.model_name.human count: group_orders.count}"
    if group_orders.count == 0
      return txt
    else
      desc = group_orders.all.map {|g| g.ordergroup.name}.join(', ')
      content_tag(:abbr, txt, title: desc).html_safe
    end
  end

  def supplier_link(order_or_supplier)
    if order_or_supplier.kind_of?(Order) and order_or_supplier.stockit?
      link_to(order_or_supplier.name, stock_articles_path).html_safe
    else
      link_to(@order.supplier.name, supplier_path(@order.supplier)).html_safe
    end
  end
end
