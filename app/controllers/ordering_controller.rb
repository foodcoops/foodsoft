# Controller for all ordering-actions that are performed by a user who is member of an Ordergroup.
# Management actions that require the "orders" role are handled by the OrdersController.
class OrderingController < ApplicationController
  # Security
  before_filter :ensure_ordergroup_member
  before_filter :ensure_open_order, :only => [:order, :saveOrder]
  
  verify :method => :post, :only => [:saveOrder], :redirect_to => { :action => :index }
  
  # Index page.
  def index    
  end
    
  # Edit a current order.
  def order       
    @open_orders = Order.open
    @other_orders = @open_orders.reject{|order| order == @order}
    # Load order article data...
    @articles_by_category = @order.get_articles
    # save results of earlier orders in array
    ordered_articles = Array.new
    @group_order = @order.group_orders.find(:first, :conditions => "ordergroup_id = #{@ordergroup.id}", :include => :group_order_articles)
    if @group_order
      # Group has already ordered, so get the results...
      for article in @group_order.group_order_articles
        result = article.orderResult
        ordered_articles[article.order_article_id] = { 'quantity' => article.quantity,
                                                   'tolerance' => article.tolerance,
                                                   'quantity_result' => result[:quantity],
                                                   'tolerance_result' => result[:tolerance]}
      end
      @version = @group_order.lock_version
      @availableFunds = @ordergroup.get_available_funds(@group_order)
    else
      @version = 0
      @availableFunds = @ordergroup.get_available_funds
    end

    # load prices ....
    @price = Array.new; @unit = Array.new;
    @others_quantity = Array.new; @quantity = Array.new; @quantity_result = Array.new; @used_quantity = Array.new; @unused_quantity = Array.new
    @others_tolerance = Array.new; @tolerance = Array.new; @tolerance_result = Array.new; @used_tolerance = Array.new; @unused_tolerance = Array.new
    i = 0;
    @articles_by_category.each do |category_name, order_articles|
      for order_article in order_articles
        # price/unit size
        @price[i] = order_article.article.fc_price
        @unit[i] = order_article.article.unit_quantity
        # quantity
        @quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id]['quantity'] : 0)
        @others_quantity[i] = order_article.quantity - @quantity[i]
        @used_quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id]['quantity_result'] : 0)
        # tolerance
        @tolerance[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id]['tolerance'] : 0)
        @others_tolerance[i] = order_article.tolerance - @tolerance[i]
        @used_tolerance[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id]['tolerance_result'] : 0)
        i += 1
      end
    end
  end
  
  # Update changes to a current order.
  def saveOrder
    order = @order # Get the object through before_filter
    if (params[:total_balance].to_i < 0)
      flash[:error] = 'Der Bestellwert übersteigt das verfügbare Guthaben.'
      redirect_to :action => 'order'
    elsif (ordered = params[:ordered])
       begin
         Order.transaction do
           # Create group order if necessary...
           if (groupOrder = order.group_orders.find(:first, :conditions => "ordergroup_id = #{@ordergroup.id}", :include => [:group_order_articles]))
              if (params[:version].to_i != groupOrder.lock_version) # check for conflicts well ahead
                raise ActiveRecord::StaleObjectError
              end
           else
              groupOrder = GroupOrder.new(:ordergroup => @ordergroup, :order => order, :updated_by => @current_user, :price => 0)
              groupOrder.save!
           end
           # Create/update GroupOrderArticles...
           newGroupOrderArticles = Array.new
           for article in order.order_articles
              # Find the GroupOrderArticle, create a new one if necessary...
              groupOrderArticles = groupOrder.group_order_articles.select{ |v| v.order_article_id == article.id }
              unless (groupOrderArticle = groupOrderArticles[0])
                groupOrderArticle = GroupOrderArticle.create(:group_order => groupOrder, :order_article_id => article.id, :quantity => 0, :tolerance => 0)           
              end
              # Get ordered quantities and update GroupOrderArticle/-Quantities...
              unless (quantities = ordered.delete(article.id.to_s)) && (quantity = quantities['quantity']) && (tolerance = quantities['tolerance'])
                quantity = tolerance = 0
              end
              groupOrderArticle.update_quantities(quantity.to_i, tolerance.to_i)
              # Add to new list of GroupOrderArticles:
              newGroupOrderArticles.push(groupOrderArticle)
           end
           groupOrder.group_order_articles = newGroupOrderArticles
           groupOrder.update_price!
           groupOrder.updated_by = @current_user
           groupOrder.save!
           order.update_quantities
           order.save!
         end         
         flash[:notice] = 'Die Bestellung wurde gespeichert.'
       rescue ActiveRecord::StaleObjectError
         flash[:error] = 'In der Zwischenzeit hat jemand anderes auch bestellt, daher konnte die Bestellung nicht aktualisiert werden.'
       rescue => exception
         logger.error('Failed to update order: ' + exception.message)
         flash[:error] = 'Die Bestellung konnte nicht aktualisiert werden, da ein Fehler auftrat.'
       end
       redirect_to :action => 'my_order_result', :id => order
    end
  end
  
  # Shows the Result for the Ordergroup the current user belongs to
  # this method decides between finished and unfinished orders
  def my_order_result
    @order= Order.find(params[:id])
    @group_order = @order.group_order(@ordergroup)
  end
  
  # Shows all Orders of the Ordergroup
  # if selected, it shows all orders of the foodcoop
  def myOrders
    # get only orders belonging to the ordergroup
    @closed_orders = Order.paginate :page => params[:page], :per_page => 10,
      :conditions => { :state => 'closed' }, :order => "orders.ends DESC"

    respond_to do |format|
      format.html # myOrders.haml
      format.js { render :partial => "orders" }
    end
  end
  
  # adds a Comment to the Order
  def add_comment
    order = Order.find(params[:id])
    comment = order.comments.build(params[:comment])
    comment.user = @current_user
    if !comment.text.empty? and comment.save
      flash[:notice] = "Kommentar wurde erstellt."
    else
      flash[:error] = "Kommentar konnte nicht erstellt werden. Leerer Kommentar?"
    end
    redirect_to :action => 'my_order_result', :id => order
  end

  private
  
  # Returns true if @current_user is member of an Ordergroup.
  # Used as a :before_filter by OrderingController.
  def ensure_ordergroup_member
    @ordergroup = @current_user.find_ordergroup
    if @ordergroup.nil?
      flash[:notice] = 'Sie gehören keiner Bestellgruppe an.'
      redirect_to :controller => root_path
    end
  end

  def ensure_open_order
    @order = Order.find(params[:id], :include => [:supplier, :order_articles])
    unless @order.open?
      flash[:notice] = 'Diese Bestellung ist bereits abgeschlossen.'
      redirect_to :action => 'index'
    end
  end

end
