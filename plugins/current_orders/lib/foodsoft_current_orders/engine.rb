module FoodsoftCurrentOrders
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      return unless FoodsoftCurrentOrders.enabled?
      return if primary[:orders].nil?

      cond = Proc.new { current_user.role_orders? }
      [
        SimpleNavigation::Item.new(primary, :stage_divider, nil, nil, class: 'divider', if: cond),
        SimpleNavigation::Item.new(primary, :current_orders_receive, I18n.t('current_orders.navigation.receive'), context.receive_current_orders_orders_path, if: cond),
        SimpleNavigation::Item.new(primary, :current_orders_articles, I18n.t('current_orders.navigation.articles'), context.current_orders_articles_path, if: cond),
        SimpleNavigation::Item.new(primary, :current_orders_ordergroups, I18n.t('current_orders.navigation.ordergroups'), context.current_orders_ordergroups_path, if: cond)
      ].each { |i| primary[:orders].sub_navigation.items << i }
    end
  end
end
