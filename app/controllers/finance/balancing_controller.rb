# encoding: utf-8
class Finance::BalancingController < Finance::BaseController

  before_filter :find_order, only: [:update_summary, :update_note, :edit_note,
                                    :confirm, :finish, :finish_direct]

  def index
    @orders = Order.closed_or_after.page(params[:page]).per(@per_page).order('ends DESC')
  end

  def new
    @order = Order.closed_or_after.find(params[:order_id])
    flash.now.alert = t('finance.balancing.new.alert') if @order.finished_or_after?
    @comments = @order.comments

    @articles = @order.order_articles.ordered_or_member.includes(:article, :article_price,
                                                       group_order_articles: {group_order: :ordergroup})

    sort_param = params['sort'] || 'name'
    @articles = case sort_param
                  when 'name' then
                    @articles.order('articles.name ASC')
                  when 'name_reverse' then
                    @articles.order('articles.name DESC')
                  when 'order_number' then
                    @articles.order('articles.order_number ASC')
                  when 'order_number_reverse' then
                    @articles.order('articles.order_number DESC')
                  else
                    @articles
                end

    render layout: false if request.xhr?
  end

  def new_on_order_article_create # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])

    render :layout => false
  end

  def new_on_order_article_update # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])

    render :layout => false
  end

  def update_summary
  end

  def edit_note
    render :layout => false
  end

  def update_note
    if @order.update_attributes(params[:order])
      render :layout => false
    else
      render :action => :edit_note, :layout => false
    end
  end

  # before the order will booked, a view lists all Ordergroups and its order_prices
  def confirm
  end

  # Balances the Order, Update of the Ordergroup.account_balances
  def finish
    @order.finish!(@current_user)
    redirect_to finance_order_index_url, notice: t('finance.balancing.close.notice') # @todo rename close to finish (+3x)

  rescue => error
    redirect_to new_finance_order_url(order_id: @order.id), alert: t('finance.balancing.close.alert', message: error.message)
  end

  # Finish the order directly, without automaticly updating ordergroups account balances
  def finish_direct
    @order.finish_direct!(@current_user)
    redirect_to finance_order_index_url, notice: t('finance.balancing.close_direct.notice')
  rescue => error
    redirect_to finance_order_index_url, alert: t('finance.balancing.close_direct.alert', message: error.message)
  end

  private

  def find_order
    @order = Order.closed_or_after.find(params[:id])
  end

end
