module FoodsoftPrinter
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      return unless FoodsoftPrinter.enabled?

      unless primary[:orders].nil?
        sub_nav = primary[:orders].sub_navigation
        sub_nav.items <<
          SimpleNavigation::Item.new(primary, :printer_jobs, I18n.t('navigation.orders.printer_jobs'), context.printer_jobs_path)
      end
    end

    def default_foodsoft_config(cfg)
      cfg[:use_printer] = false
    end

    initializer 'foodsoft_printer.order_printer_jobs' do |app|
      if Rails.configuration.cache_classes
        OrderPrinterJobs.install
      else
        ActiveSupport::Reloader.to_prepare do
          OrderPrinterJobs.install
        end
      end
    end
  end
end
