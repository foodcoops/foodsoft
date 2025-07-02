module FoodsoftB85
  class Engine < ::Rails::Engine
    config.to_prepare do
      if FoodsoftConfig[:use_b85]
        Supplier.register_remote_order_method(:ftp_b85, OrderB85)
        Supplier.include(SupplierExtensions)
        Order.include(OrderExtensions)
      end
    end
  end
end
