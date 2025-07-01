module FoodsoftB85
  class Engine < ::Rails::Engine
    config.to_prepare do
      Supplier.register_remote_order_method(:ftp_b85, OrderB85) if FoodsoftConfig[:use_b85]
    end
  end
end
