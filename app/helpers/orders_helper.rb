module OrdersHelper

  def update_articles_link(order, text, view)
    link_to_remote text, :url => order_path(order, :view => view),
      :update => 'articles', :before => "Element.show('loader')", :success => "Element.hide('loader')",
      :method => :get
  end

  def link_to_pdf(order, action)
    link_to image_tag("save_pdf.png", :size => "16x16", :border => "0", :alt => "PDF erstellen"),
      { :action => action, :id => order, :format => :pdf }, { :title => "PDF erstellen" }
  end
end
