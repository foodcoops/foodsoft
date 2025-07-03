module FoodsoftInvoices
  class Engine < ::Rails::Engine
    def default_foodsoft_config(cfg)
      cfg[:use_invoices] = false
    end
  end
end
