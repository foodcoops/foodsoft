# encoding: utf-8
module StockitHelper
  def stock_article_classes(article)
    class_names = []
    class_names << "unavailable" if article.quantity_available <= 0
    class_names.join(" ")
  end
  
  def stock_article_delete_checkbox(article)
    if article.quantity_available <= 0
      check_box_tag "stock_article_selection[stock_article_ids][]", article.id, false,
        { :id => "checkbox_#{article.id}", :title => 'Zum löschen markieren' }
    else
      check_box_tag 'checkall', '1', false,
        { :disabled => true, :title => 'Verfügbare Artikel können nicht gelöscht werden.', :class => 'unavailable' }
    end
  end
end
