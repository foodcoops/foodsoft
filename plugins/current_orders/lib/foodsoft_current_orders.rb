require "deface"
require "foodsoft_current_orders/engine"

module FoodsoftCurrentOrders
  def self.enabled?
    FoodsoftConfig[:use_current_orders]
  end
end
