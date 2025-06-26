module FoodsoftB85
  class Engine < ::Rails::Engine
    config.to_prepare do
      Supplier.add_remote_order_method_value(:ftp_b85, 'ftp_b85') if FoodsoftConfig[:use_b85]
    end
  end
end
