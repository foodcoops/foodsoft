class CurrentOrders::GroupOrdersController < ApplicationController
  # Security
  before_filter :ensure_ordergroup_member

  def index
    # XXX code duplication lib/foodsoft_current_orders/app/controllers/current_orders/ordergroups_controller.rb
    @order_ids = Order.where(state: ['open', 'finished']).all.map(&:id)
    @goas = GroupOrderArticle.includes(:group_order => :ordergroup).includes(:order_article).
              where(group_orders: {order_id: @order_ids, ordergroup_id: @ordergroup.id}).ordered
    @articles_grouped_by_category = @goas.includes(:order_article => {:article => :article_category}).
      order('articles.name').
      group_by { |a| a.order_article.article.article_category.name }.
      sort { |a, b| a[0] <=> b[0] }
  end

  private

  # XXX code duplication from GroupOrdersController
  def ensure_ordergroup_member
    @ordergroup = @current_user.ordergroup
    if @ordergroup.nil?
      redirect_to root_url, :alert => I18n.t('group_orders.errors.no_member')
    end
  end

end
