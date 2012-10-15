# encoding: utf-8
module OrdersHelper

  def update_articles_link(order, text, view)
    link_to text, order_path(order, view: view), remote: true
  end

  def order_pdf(order, document, text)
    link_to text, order_path(order, document: document, format: :pdf), title: "PDF erstellen"
  end

  def options_for_suppliers_to_select
    options = [["Lieferantin/Lager auswählen"]]
    options += Supplier.all.map {|s| [ s.name, url_for(action: "new", supplier_id: s)] }
    options += [["Lager", url_for(action: 'new', supplier_id: 0)]]
    options_for_select(options)
  end
end
