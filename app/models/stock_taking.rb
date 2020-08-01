class StockTaking < StockEvent
  def stock_change_attributes=(stock_change_attributes)
    for attributes in stock_change_attributes
      stock_changes.build(attributes) unless attributes[:quantity].to_i == 0
    end
  end
end
