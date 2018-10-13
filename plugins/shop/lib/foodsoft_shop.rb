require 'foodsoft_shop/engine'

module FoodsoftShop

  # Doorkeeper application name
  DOORKEEPER_APP_NAME = 'Foodsoft-shop'

  # Return whether the wiki is used or not.
  def self.enabled?
    !!FoodsoftConfig[:use_foodsoft_shop]
  end

  module LinkToShop
    def self.included(base) # :nodoc
      base.class_eval do
        alias_method :foodsoft_shop_orig_link_to_ordering, :link_to_ordering

        def link_to_ordering(order, options = {}, &block)
          if FoodsoftShop.enabled? && order.open?
            path = foodsoft_shop_path(anchor: "/open/orders/#{order.id}")
            name = block_given? ? capture(&block) : order.name
            link_to(name, path, options)
          else
            foodsoft_shop_orig_link_to_ordering(order, options, &block)
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  GroupOrdersHelper.send :include, FoodsoftShop::LinkToShop
end
