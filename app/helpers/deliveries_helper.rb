module DeliveriesHelper
  
  def link_to_invoice(delivery)
    if delivery.invoice
      link_to number_to_currency(delivery.invoice.amount), [:finance, delivery.invoice],
        title: I18n.t('helpers.deliveries.show_invoice')
    else
      link_to I18n.t('helpers.deliveries.new_invoice'), new_finance_invoice_path(supplier_id: delivery.supplier.id, delivery_id: delivery.id),
        class: 'btn btn-mini'
    end
  end
  
  def articles_for_select2(articles, except = [], &block)
    articles = articles.reorder('articles.name ASC')
    articles.reject! {|a| not except.index(a.id).nil? } if except
    block_given? or block = Proc.new {|a| "#{a.name} (#{number_to_currency a.price}/#{a.unit})" }
    articles.map do |a|
      {:id => a.id, :text => block.call(a)}
    end.unshift({:id => '', :text => ''})
  end
  
  def articles_for_table(articles)
    articles.undeleted.reorder('articles.name ASC')
  end
  
  def stock_change_remove_link(stock_change_form)
    return link_to t('.remove_article'), "#", :class => 'remove_new_stock_change btn btn-small' if stock_change_form.object.new_record?
    output = stock_change_form.hidden_field :_destroy
    output += link_to t('.remove_article'), "#", :class => 'destroy_stock_change btn btn-small'
    return output.html_safe
  end
  
end
