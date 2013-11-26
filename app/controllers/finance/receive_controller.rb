class Finance::ReceiveController < Finance::BaseController

  def edit
    @order = Order.find(params[:id])
    @order_articles = @order.order_articles.ordered.includes(:article)
  end

  def update
    # where to leave remainder during redistribution
    rest_to = []
    rest_to << :tolerance if params[:rest_to_tolerance]
    rest_to << :stock if params[:rest_to_stock]
    rest_to << nil
    # count what happens to the articles
    counts = [0] * (rest_to.length+2)
    cunits = [0] * (rest_to.length+2)
    OrderArticle.transaction do
      params[:order_articles].each do |oa_id, oa_params|
        unless oa_params.blank?
          oa = OrderArticle.find(oa_id)
          # update attributes; don't use update_attribute because it calls save
          # which makes received_changed? not work anymore
          oa.attributes = oa_params
          counts[0] += 1 if oa.units_received_changed?
          cunits[0] += oa.units_received * oa.article.unit_quantity
          unless oa.units_received.blank?
            oacounts = oa.redistribute oa.units_received * oa.price.unit_quantity, rest_to
            oacounts.each_with_index {|c,i| cunits[i+1]+=c; counts[i+1]+=1 if c>0 }
          end
          oa.save!
        end
      end

      #flash[:notice] = I18n.t('finance.receive.update.notice')
      notice = "Order received:"
      notice += " #{counts.shift} articles (#{cunits.shift} units) updated"
      notice += ", #{counts.shift} (#{cunits.shift}) using tolerance" if params[:rest_to_tolerance]
      notice += ", #{counts.shift} (#{cunits.shift}) go to stock if foodsoft would support that" if params[:rest_to_stock]
      notice += ", #{counts.shift} (#{cunits.shift}) left over"
      flash[:notice] = notice
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
