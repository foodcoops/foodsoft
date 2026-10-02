# frozen_string_literal: true

module BalancingControllerExtensions
  extend ActiveSupport::Concern

  included do
    def index
      multi_orders = MultiOrder.includes(:orders, :group_orders)
      orders = Order.finished.non_multi_order
      combined = (multi_orders + orders).sort_by(&:ends).reverse
      @orders = Kaminari.paginate_array(combined).page(params[:page]).per(@per_page)
    end
  end
end
