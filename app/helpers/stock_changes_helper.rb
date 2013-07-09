module StockChangesHelper

  def link_to_stock_change_reason(stock_change)
    if stock_change.delivery_id
      t '.delivery'
    elsif stock_change.order_id
      t '.order'
    elsif stock_change.stock_taking_id
      t '.stock_taking'
    end
  end

end
