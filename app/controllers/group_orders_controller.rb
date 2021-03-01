# Controller for all ordering-actions that are performed by a user who is member of an Ordergroup.
# Management actions that require the "orders" role are handled by the OrdersController.
class GroupOrdersController < ApplicationController
  # Security
  before_action :ensure_ordergroup_member
  before_action :ensure_open_order, :only => [:new, :create, :edit, :update, :order, :stock_order, :saveOrder]
  before_action :ensure_my_group_order, only: [:show, :edit, :update]
  before_action :enough_apples?, only: [:new, :create]

  # Index page.
  def index
    @closed_orders_including_group_order = Order.closed.limit(5).ordergroup_group_orders_map(@ordergroup)
    @finished_not_closed_orders_including_group_order = Order.finished_not_closed.ordergroup_group_orders_map(@ordergroup)
  end

  def new
    ordergroup = params[:stock_order] ? nil : @ordergroup
    @group_order = @order.group_orders.build(:ordergroup => ordergroup, :updated_by => current_user)
    @ordering_data = @group_order.load_data
  end

  def create
    @group_order = GroupOrder.new(params[:group_order])
    begin
      @group_order.save_ordering!
      redirect_to group_order_url(@group_order), :notice => I18n.t('group_orders.create.notice')
    rescue ActiveRecord::StaleObjectError
      redirect_to group_orders_url, :alert => I18n.t('group_orders.create.error_stale')
    rescue => exception
      logger.error('Failed to update order: ' + exception.message)
      redirect_to group_orders_url, :alert => I18n.t('group_orders.create.error_general')
    end
  end

  def show
    @order = @group_order.order
  end

  def edit
    @ordering_data = @group_order.load_data
  end

  def update
    @group_order.attributes = params[:group_order]
    @group_order.updated_by = current_user
    begin
      @group_order.save_ordering!
      redirect_to group_order_url(@group_order), :notice => I18n.t('group_orders.update.notice')
    rescue ActiveRecord::StaleObjectError
      redirect_to group_orders_url, :alert => I18n.t('group_orders.update.error_stale')
    rescue => exception
      logger.error('Failed to update order: ' + exception.message)
      redirect_to group_orders_url, :alert => I18n.t('group_orders.update.error_general')
    end
  end

  # Shows all Orders of the Ordergroup
  # if selected, it shows all orders of the foodcoop
  def archive
    # get only orders belonging to the ordergroup
    @closed_orders = Order.closed.page(params[:page]).per(10)
    @closed_orders_including_group_order = @closed_orders.ordergroup_group_orders_map(@ordergroup)
    @finished_not_closed_orders_including_group_order = Order.finished_not_closed.ordergroup_group_orders_map(@ordergroup)

    respond_to do |format|
      format.html # archive.html.haml
      format.js   # archive.js.erb
    end
  end

  private

  # Returns true if @current_user is member of an Ordergroup.
  # Used as a :before_action by OrdersController.
  def ensure_ordergroup_member
    @ordergroup = @current_user.ordergroup
    if @ordergroup.nil?
      redirect_to root_url, :alert => I18n.t('group_orders.errors.no_member')
    end
  end

  def ensure_open_order
    @order = Order.includes([:supplier, :order_articles]).find(order_id_param)
    unless @order.open?
      flash[:notice] = I18n.t('group_orders.errors.closed')
      redirect_to :action => 'index'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to group_orders_url, alert: I18n.t('group_orders.errors.notfound')
  end

  def ensure_my_group_order
    @group_order = GroupOrder.find(params[:id])
    if @group_order.ordergroup != @ordergroup && (@group_order.ordergroup || !current_user.role_orders?)
      redirect_to group_orders_url, alert: I18n.t('group_orders.errors.notfound')
    end
  end

  def enough_apples?
    if @ordergroup.not_enough_apples?
      redirect_to group_orders_url,
                  alert: t('not_enough_apples', scope: 'group_orders.messages', apples: @ordergroup.apples,
                                                stop_ordering_under: FoodsoftConfig[:stop_ordering_under])
    end
  end

  def order_id_param
    params[:order_id] || (params[:group_order] && params[:group_order][:order_id])
  end
end
