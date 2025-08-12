module FoodsoftInvoices
  class Engine < ::Rails::Engine
    config.to_prepare do
      enable_extensions! if FoodsoftInvoices.enabled?
    end

    initializer 'foodsoft_invoices.test_assets_precompile' do |app|
      app.config.assets.precompile += %w[foodsoft_invoices.js foodsoft_invoices.css] if Rails.env.test?
    end

    def default_foodsoft_config(cfg)
      cfg[:use_invoices] = false
    end
  end

  def self.enable_extensions!
    # Register assets
    Foodsoft::AssetRegistry.register_stylesheet('foodsoft_invoices')
    Foodsoft::AssetRegistry.register_javascript('foodsoft_invoices')
    # Register controller extensions
    Finance::BalancingController.include BalancingControllerExtensions
    OrdersController.include OrdersControllerExtensions
    # Register model extensions
    Group.include GroupExtensions
    GroupOrder.include GroupOrderExtensions
    Order.include OrderExtensions

    # Send group order invoices when order is closed
    ActiveSupport::Notifications.subscribe('foodsoft.order.closed') do |*args|
      order = ActiveSupport::Notifications::Event.new(*args).payload[:order]
      if FoodsoftConfig[:group_order_invoices]&.[](:use_automatic_invoices) && order.closed?
        order.group_orders.each do |go|
          goi = GroupOrderInvoice.find_or_create_by!(group_order_id: go.id)
          NotifyGroupOrderInvoiceJob.perform_later(goi) if goi.save!
        end
      end
    end
  end
end
