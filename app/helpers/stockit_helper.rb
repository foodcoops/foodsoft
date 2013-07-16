module StockitHelper
  def stock_article_classes(article)
    class_names = []
    class_names << "unavailable" if article.quantity_available <= 0
    class_names.join(" ")
  end

  def link_to_stock_change_reason(stock_change)
    if stock_change.delivery_id
      link_to t('.delivery'), supplier_delivery_path(stock_change.delivery.supplier, stock_change.delivery)
    elsif stock_change.order_id
      link_to t('.order'), order_path(stock_change.order)
    elsif stock_change.stock_taking_id
      link_to t('.stock_taking'), stock_taking_path(stock_change.stock_taking)
    end
  end
end
