module FoodsoftInvoices
  class Engine < ::Rails::Engine
    config.to_prepare do
      if FoodsoftInvoices.enabled?
        Foodsoft::AssetRegistry.register_stylesheet('foodsoft_invoices')
        Foodsoft::AssetRegistry.register_javascript('foodsoft_invoices')
        Finance::BalancingController.include BalancingControllerExtensions
        GroupOrder.include GroupOrderExtensions
        Order.include OrderExtensions
      end
    end

    def default_foodsoft_config(cfg)
      cfg[:use_invoices] = false
    end
  end
end
