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

  def stock_articles_for_select(supplier)
    supplier.stock_articles.undeleted.map {|a| ["#{a.name} (#{number_to_currency a.price}/#{a.unit})", a.id] }
  end

end
