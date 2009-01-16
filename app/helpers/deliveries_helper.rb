module DeliveriesHelper
  def articles_for_select(supplier)
    supplier.articles.find(:all, :limit => 10).collect { |a| [truncate(a.name), a.id] }
  end

  def add_article_link
    link_to_function "Artikel hinzufügen", nil, { :accesskey => 'n', :title => "ALT + SHIFT + N" } do |page|
      page.insert_html :bottom, :stock_changes, :partial => 'stock_change', :object => StockChange.new
    end
  end

end
