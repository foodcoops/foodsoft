module DeliveriesHelper

  def link_to_invoice(delivery)
    if delivery.invoice
      link_to number_to_currency(delivery.invoice.amount), [:finance, delivery.invoice],
        :title => "Rechnung anzeigen"
    else
      link_to "Rechnung anlegen", new_finance_invoice_path(:supplier_id => delivery.supplier.id, :delivery_id => delivery.id)
    end
  end

  def stock_articles_for_select(supplier)
    supplier.stock_articles.without_deleted.collect {|a| ["#{a.name} (#{number_to_currency a.price}/#{a.unit})", a.id] }
  end

end
