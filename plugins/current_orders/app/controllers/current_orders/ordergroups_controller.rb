class CurrentOrders::OrdergroupsController < ApplicationController
  before_action :authenticate_orders
  before_action :find_group_orders, only: %i[index show]

  def index
    # sometimes need to pass id as parameter for forms
    render 'show' if @ordergroup
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.js   { render :show, layout: false }
    end
  end

  def show_on_group_order_article_create
    @goa = GroupOrderArticle.find(params[:group_order_article_id])
  end

  def show_on_group_order_article_update
    # @goa = GroupOrderArticle.find(params[:group_order_article_id])
    @group_order = GroupOrder.find(params[:group_order_id])
    @ordergroup = @group_order.ordergroup
  end

  protected

  def find_group_orders
    @order_ids = Order.finished_not_closed.map(&:id)

    @all_ordergroups = Ordergroup.undeleted.order(:name).to_a
    @ordered_group_ids = GroupOrder.where(order_id: @order_ids).pluck('DISTINCT(ordergroup_id)')
    @all_ordergroups.sort_by! { |o| @ordered_group_ids.include?(o.id) ? o.name : "ZZZZZ#{o.name}" }

    @ordergroup = Ordergroup.find(params[:id]) unless params[:id].nil?
    return if @ordergroup.nil?

    @goas = GroupOrderArticle.includes(:group_order, order_article: %i[article article_version])
                             .where(group_orders: { order_id: @order_ids, ordergroup_id: @ordergroup.id }).ordered.all
  end

  helper_method \
    def articles_for_adding
    OrderArticle.includes(:article, :article_version).where(order_id: @order_ids)
  end
end
