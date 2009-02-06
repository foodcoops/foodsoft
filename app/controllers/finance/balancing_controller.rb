class Finance::BalancingController < ApplicationController
  before_filter :authenticate_finance
  verify :method => :post, :only => [:close, :close_direct]
  
  def index
    @financial_transactions = FinancialTransaction.find(:all, :order => "created_on DESC", :limit => 8)
    @orders = Order.finished_not_closed
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
        render :partial => 'edit_results_by_articles'
      when 'groupsOverview'
        render :partial => 'shared/articles_by_groups', :locals => {:order => @order}
      when 'articlesOverview'
       render :partial => 'shared/articles_by_articles', :locals => {:order => @order}
    end
  end

  def edit_note
    @order = Order.find(params[:id])
    render :partial => 'edit_note'
  end

  def update_note
    @order = Order.find(params[:id])
    render :update do |page|
      if @order.update_attributes(params[:order])
        page["note"].replace_html simple_format(@order.note)
        page["edit_box"].hide
      else
        page["results"].replace_html :partial => "edit_note"
      end
    end
  end

  #TODO: Implement create/update of articles/article_prices...
#  def new_order_article
#    @order = Order.find(params[:id])
#    order_article = @order.order_articles.build(:tax => 7, :deposit => 0)
#    render :update do |page|
#      page["edit_box"].replace_html :partial => "new_order_article", :locals => {:order_article => order_article}
#      page["edit_box"].show
#    end
#  end
#
#  def create_order_article
#    @order = Order.find(params[:order_article][:order_id])
#    order_article = OrderArticle.new(params[:order_article])
#
#    render :update do |page|
#      if order_article.save
#        page["edit_box"].hide
#        page["summary"].replace_html :partial => 'summary'
#        page.insert_html :bottom, "result_table", :partial => "order_article_result", :locals => {:order_article => order_article}
#        page["order_article_#{order_article.id}"].visual_effect :highlight, :duration => 2
#        page["group_order_articles_#{order_article.id}"].show
#      else
#        page["edit_box"].replace_html :partial => "new_order_article", :locals => {:order_article => order_article}
#      end
#    end
#  end
#
#  def editArticleResult
#    @article = OrderArticleResult.find(params[:id])
#    render :update do |page|
#       page["edit_box"].replace_html :partial => 'editArticleResult'
#       page["edit_box"].show
#    end
#  end
#
#  def updateArticleResult
#    @article = OrderArticleResult.find(params[:id])
#    @article.attributes=(params[:order_article_result]) # update attributes but doesn't save
#    @article.make_gross
#    @order = @article.order
#    @ordered_articles = @order.order_article_results
#    @group_orders = @order.group_order_results
#    render :update do |page|
#      if @article.save
#        page["edit_box"].hide
#        page["summary"].replace_html :partial => 'summary'
#        page["summary"].visual_effect :highlight, :duration => 2
#        page["order_article_result_#{@article.id}"].replace_html :partial => 'articleResult'
#        page['order_article_result_'+@article.id.to_s].visual_effect :highlight, :delay => 0.5, :duration => 2
#        page["group_order_article_results_#{@article.id}"].replace_html :partial => "groupOrderArticleResults"
#      else
#        page['edit_box'].replace_html :partial => 'editArticleResult'
#      end
#    end
#  end

  def destroy_order_article
    order_article = OrderArticle.find(params[:id])
    order_article.destroy
    @order = order_article.order
    render :update do |page|
      page["order_article_#{order_article.id}"].remove
      page["group_order_articles_#{order_article.id}"].remove
      page["summary"].replace_html :partial => 'summary', :locals => {:order => @order}
      page["summary"].visual_effect :highlight, :duration => 2
    end
  end

  def new_group_order_article
    goa = OrderArticle.find(params[:id]).group_order_articles.build
    render :update do |page|
      page["edit_box"].replace_html :partial => "new_group_order_article",
        :locals => {:group_order_article => goa}
      page["edit_box"].show
    end
  end

  # Creates a new GroupOrderArticle
  # If the the chosen Ordergroup hasn't ordered yet, a GroupOrder will also be created
  def create_group_order_article
    goa = GroupOrderArticle.new(params[:group_order_article])
    order_article = goa.order_article
    order = order_article.order
    
    # creates a new GroupOrder if necessary
    group_order = GroupOrder.first :conditions => {:order_id => order.id, :ordergroup_id => goa.ordergroup_id}
    unless group_order
      goa.create_group_order(:order_id => order.id, :ordergroup_id => goa.ordergroup_id)
    else
      goa.group_order = group_order
    end

    render :update do |page|
      if goa.save
        goa.group_order.update_price!                                       # Update the price attribute of new GroupOrder
        order_article.update_results! if order_article.article.is_a?(StockArticle)  # Update units_to_order of order_article
        page["edit_box"].hide

        page["group_order_articles_#{order_article.id}"].replace_html :partial => 'group_order_articles',
          :locals => {:order_article => order_article}
        page["group_order_article_#{goa.id}"].visual_effect :highlight, :duration => 2

        page["summary"].replace_html :partial => 'summary', :locals => {:order => order}
        page["order_profit"].visual_effect :highlight, :duration => 2
      else
        page["edit_box"].replace_html :partial => "new_group_order_article",
          :locals => {:group_order_article => goa}
      end
    end
  end

  def edit_group_order_article
    group_order_article = GroupOrderArticle.find(params[:id])
    render :partial => 'edit_group_order_article', 
      :locals => {:group_order_article => group_order_article}
  end

  def update_group_order_article
    goa = GroupOrderArticle.find(params[:id])
    
    render :update do |page|
      if goa.update_attributes(params[:group_order_article])
        goa.group_order.update_price!                     # Update the price attribute of new GroupOrder
        goa.order_article.update_results! if goa.order_article.article.is_a?(StockArticle) # Update units_to_order of order_article

        page["edit_box"].hide
        page["group_order_articles_#{goa.order_article.id}"].replace_html :partial => 'group_order_articles',
          :locals => {:order_article => goa.order_article}
        page["summary"].replace_html :partial => 'summary', :locals => {:order => goa.order_article.order}
        page["order_profit"].visual_effect :highlight, :duration => 2
      else
        page["edit_box"].replace_html :partial => 'edit_group_order_article'
      end
    end
  end

  def destroy_group_order_article
    goa = GroupOrderArticle.find(params[:id])
    goa.destroy
    goa.group_order.update_price! # Updates the price attribute of new GroupOrder
    goa.order_article.update_results! if goa.order_article.article.is_a?(StockArticle) # Update units_to_order of order_article
    
    render :update do |page|
      page["edit_box"].hide
      page["group_order_articles_#{goa.order_article.id}"].replace_html :partial => 'group_order_articles',
        :locals => {:order_article => goa.order_article}
      page["summary"].replace_html :partial => 'summary', :locals => {:order => goa.order_article.order}
      page["order_profit"].visual_effect :highlight, :duration => 2
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
      @order.close!(@current_user)
      flash[:notice] = "Bestellung wurde erfolgreich abgerechnet, die Kontostände aktualisiert."
      redirect_to :action => "index"
    rescue => e
      flash[:error] = "Ein Fehler ist beim Abrechnen aufgetreten: " + e
      redirect_to :action => "new", :id => @order
    end
  end

  # Close the order directly, without automaticly updating ordergroups account balances
  def close_direct
    @order = Order.find(params[:id])
    if @order.finished?
      @order.update_attributes(:state => 'closed', :updated_by => @current_user)
      flash[:notice] = 'Die Bestellung wurde auf "gebucht" gesetzt.'
      redirect_to :action => 'listOrders', :id => @order
    else
      flash[:error] = 'Die Bestellung ist noch nicht beendet.'
      redirect_to :action => 'listOrders', :id => @order
    end
  end

end
