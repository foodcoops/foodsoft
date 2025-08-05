module FoodsoftInvoices
  class Engine < ::Rails::Engine
    config.to_prepare do
      if FoodsoftInvoices.enabled?
        Foodsoft::AssetRegistry.register_stylesheet('foodsoft_invoices')
        Foodsoft::AssetRegistry.register_javascript('foodsoft_invoices')
        Finance::BalancingController.include BalancingControllerExtensions
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

    def default_foodsoft_config(cfg)
      cfg[:use_invoices] = false
    end
  end
end
