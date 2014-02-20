# Controller for all ordering-actions that are performed by a user who is member of an Ordergroup.
# Management actions that require the "orders" role are handled by the OrdersController.
class GroupOrdersController < ApplicationController
  # Security
  before_filter :ensure_ordergroup_member
  before_filter :ensure_open_order, :only => [:new, :create, :edit, :update, :order, :stock_order, :saveOrder]
  before_filter :ensure_my_group_order, only: [:show, :edit, :update]
  before_filter :enough_apples?, only: [:new, :create]

  # Index page.
  def index
  end

  def new
    @group_order = @order.group_orders.build(:ordergroup => @ordergroup, :updated_by => current_user)
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
    @order= @group_order.order
  end

  def edit
    @ordering_data = @group_order.load_data
  end

  def update
    @group_order.attributes = params[:group_order]
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

    respond_to do |format|
      format.html # archive.html.haml
      format.js   # archive.js.erb
    end
  end

  private

  # Returns true if @current_user is member of an Ordergroup.
  # Used as a :before_filter by OrdersController.
  def ensure_ordergroup_member
    @ordergroup = @current_user.ordergroup
    if @ordergroup.nil?
      redirect_to root_url, :alert => I18n.t('group_orders.errors.no_member')
    end
  end

  def ensure_open_order
    @order = Order.includes([:supplier, :order_articles]).find(params[:order_id] || params[:group_order][:order_id])
    unless @order.open?
      flash[:notice] = I18n.t('group_orders.errors.closed')
      redirect_to :action => 'index'
    end
  end

  def ensure_my_group_order
    @group_order = @ordergroup.group_orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to group_orders_url, alert: I18n.t('group_orders.errors.notfound')
  end

  def enough_apples?
    if @ordergroup.not_enough_apples?
      redirect_to group_orders_url,
                  alert: t('not_enough_apples', scope: 'group_orders.messages', apples: @ordergroup.apples,
                           stop_ordering_under: FoodsoftConfig[:stop_ordering_under])
    end
  end

end
