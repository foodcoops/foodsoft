# encoding: utf-8
module OrdersHelper

  def update_articles_link(order, text, view)
    link_to text, order_path(order, view: view), remote: true
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

  def units_history_line(order_article)
    if order_article.order.open?
      nil
    else
      units_info = "#{order_article.units_to_order} #{heading_helper OrderArticle, :units_to_order}"
      units_info += ", #{order_article.units_billed} #{heading_helper OrderArticle, :units_billed}" unless order_article.units_billed.nil?
      units_info += ", #{order_article.units_received} #{heading_helper OrderArticle, :units_received}" unless order_article.units_received.nil?
    end
  end

  # can be article or article_price
  def pkg_helper(article, icon=true)
    return nil if article.unit_quantity == 1
    if icon
      "<i class='package'> &times; #{article.unit_quantity}</i>".html_safe
    else
      "<span class='package'> &times; #{article.unit_quantity}</span>".html_safe
    end
  end
  
  def article_price_change_hint(order_article, gross=false)
    return nil if order_article.article.price == order_article.price.price
    title = "#{t('helpers.orders.old_price')}: #{number_to_currency order_article.article.price}"
    title += " / #{number_to_currency order_article.article.gross_price}" if gross
    "<i class='icon-asterisk' title='#{j title}'></i>".html_safe
  end
  
  def receive_input_field(form)
    order_article = form.object
    units_expected = (order_article.units_billed or order_article.units_to_order)
    
    # unlock button, to prevent overwriting if it was manually distributed
    input_html = ''
    if order_article.result_manually_changed?
      input_html += '<span class="input-prepend intable">' +
        button_tag(nil, type: :button, class: 'btn unlocker', title: t('.locked_to_protect_unlock_button')) {'<i class="icon icon-unlock"></i>'.html_safe}
    end
    
    input_html += form.text_field :units_received, class: 'input input-nano package units_received',
      data: {'units-expected' => units_expected},
      disabled: order_article.result_manually_changed?,
      title: order_article.result_manually_changed? ? t('.locked_to_protect_manual_update') : nil,
      autocomplete: 'off'
    
    input_html += '</span>' if order_article.result_manually_changed?
    input_html.html_safe
  end
end
