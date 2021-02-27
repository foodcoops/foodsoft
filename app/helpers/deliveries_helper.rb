module DeliveriesHelper
  def link_to_invoice(delivery)
    if delivery.invoice
      link_to number_to_currency(delivery.invoice.amount), [:finance, delivery.invoice],
              title: I18n.t('helpers.deliveries.show_invoice')
    else
      link_to I18n.t('helpers.deliveries.new_invoice'), new_finance_invoice_path(supplier_id: delivery.supplier.id, delivery_id: delivery.id),
              class: 'btn btn-default btn-xs'
    end
  end

  def articles_for_select2(articles, except = [], &block)
    articles = articles.reorder('article_versions.name ASC')
    articles = articles.reject { |a| !except.index(a.id).nil? } if except
    block_given? or block = proc { |a| "#{a.name} (#{number_to_currency a.price}/#{a.unit})" }
    articles.map do |a|
      { id: a.id, text: block.call(a) }
    end.unshift({ id: '', text: '' })
  end

  def order_articles_for_select2(order_articles, exclude_ids = [])
    order_articles = order_articles.joins(:article).reorder('articles.name ASC')
    order_articles.select { |a| exclude_ids.index(a.id).nil? } if exclude_ids
  end

  def articles_for_table(articles)
    articles.undeleted.reorder('article_versions.name ASC')
  end

  def stock_change_remove_link(stock_change_form)
    if stock_change_form.object.new_record?
      return link_to t('deliveries.stock_change_fields.remove_article'), '#',
                     class: 'remove_new_stock_change btn btn-default btn-sm'
    end

    output = stock_change_form.hidden_field :_destroy
    output += link_to t('deliveries.stock_change_fields.remove_article'), '#',
                      class: 'destroy_stock_change btn btn-default btn-sm'
    output.html_safe
  end
end
