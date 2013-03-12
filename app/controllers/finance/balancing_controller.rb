# encoding: utf-8
class Finance::BalancingController < Finance::BaseController

  def index
    @orders = Order.finished.page(params[:page]).per(@per_page).order('ends DESC')
  end

  def new
    @order = Order.find(params[:order_id])
    flash.now.alert = "Achtung, Bestellung wurde schon abgerechnet" if @order.closed?
    @comments = @order.comments

    @articles = @order.order_articles.ordered.includes(:order, :article_price,
                                                       group_order_articles: {group_order: :ordergroup})

    sort_param = params['sort'] || 'name'
    @articles = case sort_param
                  when 'name' then
                    OrderArticle.sort_by_name(@articles)
                  when 'name_reverse' then
                    OrderArticle.sort_by_name(@articles).reverse
                  when 'order_number' then
                    OrderArticle.sort_by_order_number(@articles)
                  when 'order_number_reverse' then
                    OrderArticle.sort_by_order_number(@articles).reverse
                  else
                    @articles
                end

    render layout: false if request.xhr?
  end

  def edit_note
    @order = Order.find(params[:id])
    render :layout => false
  end

  def update_note
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      render :layout => false
    else
      render :action => :edit_note, :layout => false
    end
  end

  # before the order will booked, a view lists all Ordergroups and its order_prices
  def confirm
    @order = Order.find(params[:id])
  end

  # Balances the Order, Update of the Ordergroup.account_balances
  def close
    @order = Order.find(params[:id])
    @order.close!(@current_user)
    redirect_to finance_root_url, notice: "Bestellung wurde erfolgreich abgerechnet, die Kontostände aktualisiert."

  rescue => error
    redirect_to new_finance_order_url(order_id: @order.id), alert: "Ein Fehler ist beim Abrechnen aufgetreten: #{error.message}"
  end

  # Close the order directly, without automaticly updating ordergroups account balances
  def close_direct
    @order = Order.find(params[:id])
    @order.close_direct!(@current_user)
    redirect_to finance_balancing_url, notice: "Bestellung wurde geschlossen."
  rescue => error
    redirect_to finance_balancing_url, alert: "Bestellung kann nicht geschlossen werden: #{error.message}"
  end

end
