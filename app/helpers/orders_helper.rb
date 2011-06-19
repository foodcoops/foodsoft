module OrdersHelper

  def update_articles_link(order, text, view)
    link_to text, order_path(order, :view => view), :remote => true
  end

  def link_to_pdf(order, action)
    link_to image_tag("save_pdf.png", :size => "16x16", :border => "0", :alt => "PDF erstellen"),
      { :action => action, :id => order, :format => :pdf }, { :title => "PDF erstellen" }
  end

  def options_for_suppliers_to_select
    options = [["Lieferantin/Lager auswählen"]]
    options += Supplier.all.map {|s| [ s.name, url_for(:action => "new", :supplier_id => s)] }
    options += [["Lager", url_for(:action => 'new', :supplier_id => 0)]]
    options_for_select(options)
  end
end
