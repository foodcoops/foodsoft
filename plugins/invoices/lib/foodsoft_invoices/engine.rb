module FoodsoftInvoices
  class Engine < ::Rails::Engine
    config.to_prepare do
      GroupOrder.include GroupOrderExtensions if FoodsoftInvoices.enabled?
    end

    def default_foodsoft_config(cfg)
      cfg[:use_invoices] = false
    end
  end
end
