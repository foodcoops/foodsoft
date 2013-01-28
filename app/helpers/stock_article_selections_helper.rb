# encoding: utf-8
module StockArticleSelectionsHelper
  def article_deletion_classes(article)
    className = "label label-success" # usual deletable case, maybe modified below
    className = "label label-important" if article.quantity_available > 0
    className = "label" if article.deleted?
    
    className
  end
  
  def article_deletion_title(article)
    myTitle = "Löschbar" # usual deletable case, maybe modified below
    myTitle = "Nicht löschbar, da im Lager vorhanden" if article.quantity_available > 0
    myTitle = "Bereits gelöscht" if article.deleted?
    
    myTitle
  end
end
