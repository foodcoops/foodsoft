module DeliveriesHelper
  def articles_for_select(supplier)
    supplier.articles.find(:all, :limit => 10).collect { |a| [truncate(a.name), a.id] }
  end

  def add_article_link
    link_to_function "Artikel hinzufügen", nil, { :accesskey => 'n', :title => "ALT + SHIFT + N" } do |page|
      page.insert_html :bottom, :stock_changes, :partial => 'stock_change', :object => StockChange.new
    end
  end

  def link_to_invoice(delivery)
    if delivery.invoice
      link_to number_to_currency(delivery.invoice.amount), [:finance, delivery.invoice],
        :title => "Rechnung anzeigen"
    else
      link_to "Rechnung anlegen", new_finance_invoice_path(:supplier_id => delivery.supplier.id, :delivery_id => delivery.id)
    end
  end

end
