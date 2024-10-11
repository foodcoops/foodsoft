class Finance::BalancingController < Finance::BaseController
  def index
    @orders = Order.finished.page(params[:page]).per(@per_page).order('ends DESC')
  end

  def new
    @order = Order.find(params[:order_id])
    flash.now.alert = t('.alert') if @order.closed?
    @comments = @order.comments

    @articles = @order.order_articles.ordered_or_member.includes(article_version: :article,
                                                                 group_order_articles: { group_order: :ordergroup })

    sort_param = params['sort'] || 'name'
    @articles = case sort_param
                when 'name'
                  @articles.order('article_versions.name ASC')
                when 'name_reverse'
                  @articles.order('article_versions.name DESC')
                when 'order_number'
                  @articles.order('article_versions.order_number ASC')
                when 'order_number_reverse'
                  @articles.order('article_versions.order_number DESC')
                else
                  @articles
                end

    render layout: false if request.xhr?
  end

  def new_on_order_article_create # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])

    render layout: false
  end

  def new_on_order_article_update # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])

    render layout: false
  end

  def update_summary
    @order = Order.find(params[:id])
  end

  def edit_note
    @order = Order.find(params[:id])
    render layout: false
  end

  def update_note
    @order = Order.find(params[:id])
    if @order.update(params[:order])
      render layout: false
    else
      render action: :edit_note, layout: false
    end
  end

  def edit_transport
    @order = Order.find(params[:id])
    render layout: false
  end

  def update_transport
    @order = Order.find(params[:id])
    @order.update!(params[:order])
    redirect_to new_finance_order_path(order_id: @order.id)
  rescue StandardError => e
    redirect_to new_finance_order_path(order_id: @order.id), alert: t('errors.general_msg', msg: e.message)
  end

  # before the order will booked, a view lists all Ordergroups and its order_prices
  def confirm
    @order = Order.find(params[:id])
  end

  # Balances the Order, Update of the Ordergroup.account_balances
  def close
    @order = Order.find(params[:id])
    @type = FinancialTransactionType.find_by_id(params.permit(:type)[:type])
    @link = FinancialLink.new if params[:create_financial_link]
    @order.close!(@current_user, @type, @link, create_foodcoop_transaction: params[:create_foodcoop_transaction])
    redirect_to finance_order_index_url, notice: t('.notice')
  rescue StandardError => e
    redirect_to new_finance_order_url(order_id: @order.id), alert: t('.alert', message: e.message)
  end

  # Close the order directly, without automaticly updating ordergroups account balances
  def close_direct
    @order = Order.find(params[:id])
    @order.close_direct!(@current_user)
    redirect_to finance_order_index_url, notice: t('.notice')
  rescue StandardError => e
    redirect_to finance_order_index_url, alert: t('.alert', message: e.message)
  end

  def close_all_direct_with_invoice
    count = 0
    Order.transaction do
      Order.finished_not_closed.with_invoice.each do |order|
        order.close_direct! current_user
        count += 1
      end
    end
    redirect_to finance_order_index_url, notice: t('.notice', count: count)
  rescue StandardError => e
    redirect_to finance_order_index_url, alert: t('errors.general_msg', msg: e.message)
  end
end
