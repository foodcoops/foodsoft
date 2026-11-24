module Pickup
  # Group orders of an ordergroup that are waiting to be picked up.
  #
  # This is what a member's pickup app asks for: always the ordergroup of the
  # user holding the token, so there is no ordergroup_id parameter, no orders
  # role, and a plain app token ('group_orders:user') is enough.
  #
  # The window of orders that counts as "waiting for pickup" lives in
  # Pickup::Orders.
  class GroupOrdersController < BaseController
    include Pickup::Orders

    before_action -> { doorkeeper_authorize! 'group_orders:user' }
    before_action :require_ordergroup

    def index
      group_orders = pickup_group_orders(current_ordergroup)

      render json: group_orders, each_serializer: Pickup::GroupOrderSerializer,
                                 root: 'group_orders',
                                 meta: { window_weeks: Pickup::Orders::WINDOW_WEEKS,
                                         limit: Pickup::Orders::LIMIT }
    end
  end
end
