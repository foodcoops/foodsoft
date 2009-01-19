class Finance::BalancingController < ApplicationController
  before_filter :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.find(:all, :order => "created_on DESC", :limit => 8)
    @orders = Order.find(:all, :conditions => 'finished = 1 AND booked = 0', :order => 'ends DESC')
    @unpaid_invoices = Invoice.unpaid
  end

  def list
    @orders = Order.finished.paginate :page => params[:page], :per_page => 10, :order => 'ends DESC'
  end

  def new
    @order = Order.find(params[:id])
    @comments = @order.comments
    case params[:view]
      when 'editResults'
        render :partial => 'editResults'
      when 'groupsOverview'
        render :partial => 'groupsOverview'
      when 'articlesOverview'
       render :partial => 'articlesOverview'
      when "editNote"
        render :partial => "editNote"
    end
  end

   def newArticleResult
    @order = Order.find(params[:id])
    @article = @order.order_article_results.build(:tax => 7, :deposit => 0)
    render :update do |page|
      page["edit_box"].replace_html :partial => "newArticleResult"
      page["edit_box"].show
    end
  end

  def createArticleResult
    render :update do |page|
      @article = OrderArticleResult.new(params[:order_article_result])
      @article.fc_markup = APP_CONFIG[:price_markup]
      @article.make_gross if @article.tax && @article.deposit && @article.net_price
      if @article.valid?
        @article.save
        @order = @article.order
        page["edit_box"].hide
        page["order_summary"].replace_html :partial => 'summary'
        page.insert_html :bottom, "result_table", :partial => "articleResults"
        page["order_article_result_#{@article.id}"].visual_effect :highlight, :duration => 2
        page["group_order_article_results_#{@article.id}"].show
      else
        page["edit_box"].replace_html :partial => "newArticleResult"
      end
    end
  end

  def editArticleResult
    @article = OrderArticleResult.find(params[:id])
    render :update do |page|
       page["edit_box"].replace_html :partial => 'editArticleResult'
       page["edit_box"].show
    end
  end

  def updateArticleResult
    @article = OrderArticleResult.find(params[:id])
    @article.attributes=(params[:order_article_result]) # update attributes but doesn't save
    @article.make_gross
    @order = @article.order
    @ordered_articles = @order.order_article_results
    @group_orders = @order.group_order_results
    render :update do |page|
      if @article.save
        page["edit_box"].hide
        page["order_summary"].replace_html :partial => 'summary'
        page["order_summary"].visual_effect :highlight, :duration => 2
        page["order_article_result_#{@article.id}"].replace_html :partial => 'articleResult'
        page['order_article_result_'+@article.id.to_s].visual_effect :highlight, :delay => 0.5, :duration => 2
        page["group_order_article_results_#{@article.id}"].replace_html :partial => "groupOrderArticleResults"
      else
        page['edit_box'].replace_html :partial => 'editArticleResult'
      end
    end
  end

  def destroyArticleResult
    if @article = OrderArticleResult.find(params[:id]).destroy
      @order = @article.order
      render :update do |page|
        page["order_article_result_#{@article.id}"].remove
        page["group_order_article_results_#{@article.id}"].remove
        page["order_summary"].replace_html :partial => 'summary'
        page["order_summary"].visual_effect :highlight, :duration => 2
      end
    end
  end

  def newGroupResult
    @result = OrderArticleResult.find(params[:id]).group_order_article_results.build
    render :update do |page|
      page["edit_box"].replace_html :partial => "newGroupResult"
      page["edit_box"].show
    end
  end

  # Creates a new GroupOrderArticleResult
  # If the the chosen Ordergroup hasn't ordered yet, a GroupOrderResult will created
  def createGroupResult
    @result = GroupOrderArticleResult.new(params[:group_order_article_result])
    order = @result.order_article_result.order
    orderGroup = Ordergroup.find(params[:group_order_article_result][:group_order_result_id])
    # creates a new GroupOrderResult if necessary
    unless @result.group_order_result = GroupOrderResult.find(:first,
                                                          :conditions => ["group_order_results.group_name = ? AND group_order_results.order_id = ?", orderGroup.name, order.id ])
      @result.group_order_result = GroupOrderResult.create(:order => order, :group_name => orderGroup.name)
    end
    render :update do |page|
      if @result.valid? && @result.save
        @result.group_order_result.updatePrice #updates the price attribute
        article = @result.order_article_result
        page["edit_box"].hide
        page.insert_html :after, "groups_results_#{article.id}", :partial => "groupResults"
        page["group_order_article_result_#{@result.id}"].visual_effect :highlight, :duration => 2
        page["groups_amount"].replace_html number_to_currency(article.order.sumPrice('groups'))
        page["fcProfit"].replace_html number_to_currency(article.order.fcProfit)
        page["fcProfit"].visual_effect :highlight, :duration => 2

        # get the new sums for quantity and price and replace it
        total = article.total
        page["totalArticleQuantity_#{article.id}"].replace_html total[:quantity]
        page["totalArticlePrice_#{article.id}"].replace_html number_to_currency(total[:price])
      else
        page["edit_box"].replace_html :partial => "newGroupResult"
      end
    end
  end

  def updateGroupResult
    @result = GroupOrderArticleResult.find(params[:id])
    render :update do |page|
      if params[:group_order_article_result]
        if @result.update_attribute(:quantity, params[:group_order_article_result][:quantity])
          order = @result.group_order_result.order
          groups_amount = order.sumPrice("groups")
          article = @result.order_article_result
          total = article.total

          page["edit_box"].hide
          page["groups_amount"].replace_html number_to_currency(groups_amount)
          page["fcProfit"].replace_html number_to_currency(order.fcProfit)
          page["groups_amount"].visual_effect :highlight, :duration => 2
          page["fcProfit"].visual_effect :highlight, :duration => 2
          page["group_order_article_result_#{@result.id}"].replace_html :partial => "groupResult"
          page["group_order_article_result_#{@result.id}"].visual_effect :highlight, :duration => 2
          page["totalArticleQuantity_#{article.id}"].replace_html total[:quantity]
          page["totalArticlePrice_#{article.id}"].replace_html total[:price]
          page["sum_of_article_#{article.id}"].visual_effect :highlight, :duration => 2
        end
      else
        page["edit_box"].replace_html :partial => 'editGroupResult'
        page["edit_box"].show
      end
    end
  end

  def destroyGroupResult
    @result = GroupOrderArticleResult.find(params[:id])
    if @result.destroy
      render :update do |page|
        article = @result.order_article_result
        page["group_order_article_result_#{@result.id}"].remove
        page["groups_amount"].replace_html number_to_currency(article.order.sumPrice('groups'))
        page["fcProfit"].replace_html number_to_currency(article.order.fcProfit)
        page["fcProfit"].visual_effect :highlight, :duration => 2
        total = article.total # get total quantity and price for the ArticleResult
        page["totalArticleQuantity_#{article.id}"].replace_html total[:quantity]
        page["totalArticleQuantity_#{article.id}"].visual_effect :highlight, :duration => 2
        page["totalArticlePrice_#{article.id}"].replace_html number_to_currency(total[:price])
        page["totalArticlePrice_#{article.id}"].visual_effect :highlight, :duration => 2
      end
    end
  end

  def editOrderSummary
    @order = Order.find(params[:id])
    render :update do |page|
      page["edit_box"].replace_html :partial => 'editSummary'
      page["edit_box"].show
    end
  end

  def updateOrderSummary
    @order = Order.find(params[:id])
    render :update do |page|
      if @order.update_attributes(params[:order])
        page["edit_box"].hide
        page["order_summary"].replace_html :partial => "summary"
        page["clear_invoice"].visual_effect :highlight, :duration => 2
      else
        page["edit_box"].replace_html :partial => 'editSummary'
      end
    end
  end

  def updateOrderNote
    @order = Order.find(params[:id])
    render :update do |page|
      if @order.update_attribute(:note, params[:order][:note])
        page["note"].replace_html simple_format(@order.note)
        page["results"].replace_html :partial => "groupsOverview"
      else
        page["results"].replace_html :partial => "editNote"
      end
    end
  end

  # before the order will booked, a view lists all Ordergroups and its order_prices
  def confirm
    @order = Order.find(params[:id])
  end

  # Balances the Order, Update of the Ordergroup.account_balances
  def close
    @order = Order.find(params[:id])
    begin
      @order.balance(@current_user)
      flash[:notice] = "Bestellung wurde erfolgreich abgerechnet, die Kontostände aktualisiert."
      redirect_to :action => "index"
    rescue => e
      flash[:error] = "Ein Fehler ist beim Abrechnen aufgetreten: " + e
      redirect_to :action =>"editOrder", :id => @order
    end
  end

  # Set all GroupOrders that belong to this finished order to status 'booked'.
  def setAllBooked
    @order = Order.find(params[:id])
    if (@order.finished?)
      @order.booked = true
      @order.updated_by = @current_user
      @order.save!
      flash[:notice] = 'Die Bestellung wurde auf "gebucht" gesetzt.'
      redirect_to :action => 'listOrders', :id => @order
    else
      flash[:error] = 'Die Bestellung ist noch nicht beendet.'
      redirect_to :action => 'listOrders', :id => @order
    end
  end

end
