# encoding: utf-8
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

    if params['sort']
      sort = case params['sort']
             when "name"  then "articles.name"
             when "order_number" then "articles.order_number"
             when "name_reverse"  then "articles.name DESC"
             when "order_number_reverse" then "articles.order_number DESC"
             end
    else
      sort = "id"
    end

    @articles = @order.order_articles.ordered.find(
      :all,
      :include => :article,
      :order => sort
    )
      
    if params[:sort] == "order_number"
      @articles = @articles.sort { |a,b| a.article.order_number.gsub(/[^[:digit:]]/, "").to_i <=> b.article.order_number.gsub(/[^[:digit:]]/, "").to_i }
    elsif params[:sort] == "order_number_reverse"
      @articles = @articles.sort { |a,b| b.article.order_number.gsub(/[^[:digit:]]/, "").to_i <=> a.article.order_number.gsub(/[^[:digit:]]/, "").to_i }
    end

    view = params[:view]
    params[:view] = nil

    case view
      when 'editResults'
        render :partial => 'edit_results_by_articles' and return
      when 'groupsOverview'
        render :partial => 'shared/articles_by_groups', :locals => {:order => @order} and return
      when 'articlesOverview'
       render :partial => 'shared/articles_by_articles', :locals => {:order => @order} and return
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

  def new_order_article
    @order = Order.find(params[:id])
    render :update do |page|
      page["edit_box"].replace_html :partial => "new_order_article"
      page["edit_box"].show
    end
  end
  
  def auto_complete_for_article_name
    order = Order.find(params[:order_id])
    find_params = {
      :conditions => ["LOWER(articles.name) LIKE ?", "%#{params[:article][:name].downcase}%" ],
      :order => 'articles.name ASC',
      :limit => 8
    }
    @articles = if order.stockit?
      StockArticle.all find_params
    else
      order.supplier.articles.all find_params
    end
  
    render :partial => 'shared/auto_complete_articles'
  end
  
  def create_order_article
    @order = Order.find(params[:order_id])
    article = Article.find(params[:order_article][:article_id])
    order_article = @order.order_articles.find_by_article_id(article.id)

    unless order_article
      # Article wasn't already assigned with this order, lets create a new one
      order_article = @order.order_articles.build(params[:order_article])
      order_article.article_price = order_article.article.article_prices.first
    end
    # Set units to order to 1, so the article is visible on page
    order_article.units_to_order = 1
    
    render :update do |page|
      if order_article.save
        page["edit_box"].hide
        page.insert_html :top, "result_table", :partial => "order_article_result", :locals => {:order_article => order_article}
        page["order_article_#{order_article.id}"].visual_effect :highlight, :duration => 2
        page["group_order_articles_#{order_article.id}"].show
      else
        page["edit_box"].replace_html :partial => "new_order_article"
      end
    end

  rescue
    render :update do |page|
      page.replace_html "edit_box", :text => "<b>Keinen Artikel gefunden. Bitte erneut versuchen.</b>"
      page.insert_html :bottom, "edit_box", :partial => "new_order_article"
    end
  end

  def edit_order_article
    @order_article = OrderArticle.find(params[:id])
    render :update do |page|
       page["edit_box"].replace_html :partial => 'edit_order_article'
       page["edit_box"].show
    end
  end

  # Update this article and creates a new articleprice if neccessary
  def update_order_article
    @order_article = OrderArticle.find(params[:id])
    begin
      @order_article.update_article_and_price!(params[:article], params[:price], params[:order_article])
      render :update do |page|
        page["edit_box"].hide
        page["summary"].replace_html :partial => 'summary', :locals => {:order => @order_article.order}
        page["summary"].visual_effect :highlight, :duration => 2
        page["order_article_#{@order_article.id}"].replace_html :partial => 'order_article', :locals => {:order_article => @order_article}
        page["order_article_#{@order_article.id}"].visual_effect :highlight, :delay => 0.5, :duration => 2
        page["group_order_articles_#{@order_article.id}"].replace_html :partial => "group_order_articles", :locals => {:order_article => @order_article}
      end
    rescue => @error
      render :update do |page|
        page['edit_box'].replace_html :partial => 'edit_order_article'
      end
    end
  end

  def destroy_order_article
    order_article = OrderArticle.find(params[:id])
    order_article.destroy
    # Updates ordergroup values
    order_article.group_order_articles.each { |goa| goa.group_order.update_price! }
    
    render :update do |page|
      page["order_article_#{order_article.id}"].remove
      page["group_order_articles_#{order_article.id}"].remove
      page["summary"].replace_html :partial => 'summary', :locals => {:order => order_article.order}
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
  #FIXME: Clean up this messy code !
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

    # If there is an GroupOrderArticle already, only update result attribute.
    if group_order_article = GroupOrderArticle.first(:conditions => {:group_order_id => goa.group_order, :order_article_id => goa.order_article})
      goa = group_order_article
      goa.result = params[:group_order_article]["result"]
    end
    
    render :update do |page|
      if goa.save
        goa.group_order.update_price!                                       # Update the price attribute of new GroupOrder
        order_article.update_results! if order_article.article.is_a?(StockArticle)  # Update units_to_order of order_article
        page["edit_box"].hide
        page["order_article_#{order_article.id}"].replace_html :partial => 'order_article', :locals => {:order_article => order_article}

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
        page["order_article_#{goa.order_article.id}"].replace_html :partial => 'order_article', :locals => {:order_article => goa.order_article}
        page["group_order_articles_#{goa.order_article.id}"].replace_html :partial => 'group_order_articles',
          :locals => {:order_article => goa.order_article}
        page["summary"].replace_html :partial => 'summary', :locals => {:order => goa.order_article.order}
        page["order_profit"].visual_effect :highlight, :duration => 2
      else
        page["edit_box"].replace_html :partial => 'edit_group_order_article'
      end
    end
  end

  def update_group_order_article_result
    goa = GroupOrderArticle.find(params[:id])

    if params[:modifier] == '-'
      goa.update_attributes({:result => goa.result - 1})
    elsif params[:modifier] == '+'
      goa.update_attributes({:result => goa.result + 1})
    end

    render :update do |page|
        goa.group_order.update_price!                     # Update the price attribute of new GroupOrder
        goa.order_article.update_results! if goa.order_article.article.is_a?(StockArticle) # Update units_to_order of order_article

        page["order_article_#{goa.order_article.id}"].replace_html :partial => 'order_article', :locals => {:order_article => goa.order_article}
        page["group_order_articles_#{goa.order_article.id}"].replace_html :partial => 'group_order_articles',
          :locals => {:order_article => goa.order_article}
        page["summary"].replace_html :partial => 'summary', :locals => {:order => goa.order_article.order}
        page["order_profit"].visual_effect :highlight, :duration => 2
    end

  end

  def destroy_group_order_article
    goa = GroupOrderArticle.find(params[:id])
    goa.destroy
    goa.group_order.update_price! # Updates the price attribute of new GroupOrder
    goa.order_article.update_results! if goa.order_article.article.is_a?(StockArticle) # Update units_to_order of order_article
    
    render :update do |page|
      page["edit_box"].hide
      page["order_article_#{goa.order_article.id}"].replace_html :partial => 'order_article', :locals => {:order_article => goa.order_article}
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
