class Finance::ReceiveController < Finance::BaseController

  def edit
    @order = Order.find(params[:id])
    @order_articles = @order.order_articles.ordered.includes(:article)
  end

  def update
    OrderArticle.transaction do
      params[:order_articles].each do |oa_id, oa_params|
        unless oa_params.blank?
          oa = OrderArticle.find(oa_id)
          # update attributes
          oa.update_attributes!(oa_params)
          # and process consequences
          oa.redistribute(oa.units_received * oa.price.unit_quantity) unless oa.units_received.blank?
          oa.save!
        end
      end

      flash[:notice] = I18n.t('finance.receive.update.notice')
      redirect_to finance_order_index_path
    end
  end

  # ajax add article
  def add_article
    @order = Order.find(params[:receive_id])
    @order_article = @order.order_articles.where(:article_id => params[:article_id]).includes(:article).first
    # we need to create the order article if it's not part of the current order
    if @order_article.nil?
      @order_article = @order.order_articles.build({order: @order, article_id: params[:article_id]})
      @order_article.save!
    end
  end

end
