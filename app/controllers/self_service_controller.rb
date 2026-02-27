# Controller for self service: Correcting received amounts and performing transactions for the
# logged in ordergroup without finance permissions
class SelfServiceController < ApplicationController
  before_action :ensure_ordergroup_member
  before_action -> { require_config_enabled :use_self_service }

  def index
    @group_orders = @ordergroup
                    .group_orders
                    .joins(:order)
                    .where(orders: { state: 'received' })
                    .order('orders.ends DESC')
                    .page(params[:page]).per(10)

    @financial_transactions = @ordergroup
                              .financial_transactions.order('created_on DESC')
                              .limit(10)
  end

  private

  # Returns true if @current_user is member of an Ordergroup.
  # Used as a :before_action by OrdersController.
  # TODO: This is an exact copy of GroupOrdersController#ensure_ordergroup_member
  # -> Maybe merge it:
  def ensure_ordergroup_member
    @ordergroup = @current_user.ordergroup
    return unless @ordergroup.nil?

    redirect_to root_url, alert: I18n.t('group_orders.errors.no_member')
  end
end
