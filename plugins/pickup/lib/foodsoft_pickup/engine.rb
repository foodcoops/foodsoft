module FoodsoftPickup
  class Engine < ::Rails::Engine
    def default_foodsoft_config(cfg)
      cfg[:use_pickup] = false
    end
  end
end
