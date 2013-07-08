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
  
  def articles_for_select2(supplier)
    supplier.articles.undeleted.reorder('articles.name ASC').map {|a| {:id => a.id, :text => "#{a.name} (#{number_to_currency a.price}/#{a.unit})"} }
  end
  
  def stock_articles_for_table(supplier)
    supplier.stock_articles.undeleted.reorder('articles.name ASC')
  end
  
  def stock_change_remove_link(stock_change_form)
    return link_to t('.remove_article'), "#", :class => 'remove_new_stock_change btn btn-small' if stock_change_form.object.new_record?
    output = stock_change_form.hidden_field :_destroy
    output += link_to t('.remove_article'), "#", :class => 'destroy_stock_change btn btn-small'
    return output.html_safe
  end
  
  def stock_article_price_hint(stock_article)
    t('simple_form.hints.stock_article.edit_stock_article.price',
      :stock_article_copy_link => link_to(t('.copy_stock_article'),
        copy_stock_article_supplier_deliveries_path(@supplier, :old_stock_article_id => stock_article.id),
        :remote => true
      )
    )
  end
  
end
