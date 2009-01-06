# Controller for all ordering-actions that are performed by a user who is member of an OrderGroup.
# Management actions that require the "orders" role are handled by the OrdersController.
class OrderingController < ApplicationController
  # Security
  before_filter :ensureOrderGroupMember
  verify :method => :post, :only => [:saveOrder], :redirect_to => { :action => :index }
  
  # Messages
  ERROR_ALREADY_FINISHED = 'Diese Bestellung ist bereits abgeschlossen.'
  ERROR_NO_ORDERGROUP = 'Sie gehören keiner Bestellgruppe an.'
  ERROR_INSUFFICIENT_FUNDS = 'Der Bestellwert übersteigt das verfügbare Guthaben.'
  MSG_ORDER_UPDATED = 'Die Bestellung wurde gespeichert.'
  MSG_ORDER_CREATED = 'Die Bestellung wurde angelegt.'
  ERROR_UPDATE_FAILED = 'Die Bestellung konnte nicht aktualisiert werden, da ein Fehler auftrat.'
  ERROR_UPDATE_CONFLICT = 'In der Zwischenzeit hat jemand anderes auch bestellt, daher konnte die Bestellung nicht aktualisiert werden.'
  
  # Index page.
  def index
    @orderGroup = @current_user.find_ordergroup
    @currentOrders = Order.find_current
    @finishedOrders = @orderGroup.findExpiredOrders + @orderGroup.findFinishedNotBooked
    @bookedOrders = @orderGroup.findBookedOrders(5)
    
    # Calculate how much the order group has spent on open or nonbooked orders:
    @currentOrdersValue, @nonbookedOrdersValue = 0, 0
    @orderGroup.findCurrent.each { |groupOrder| @currentOrdersValue += groupOrder.price}
    @finishedOrders.each { |groupOrder| @nonbookedOrdersValue += groupOrder.price}
  end
    
  # Edit a current order.
  def order       
    @order = Order.find(params[:id], :include => [:supplier, :order_articles])
    if !@order.current?
      flash[:notice] = ERROR_ALREADY_FINISHED
      redirect_to :action => 'index'
    elsif !(@order_group = @current_user.find_ordergroup)
      flash[:notice] = ERROR_NO_ORDERGROUP
      redirect_to :controller => 'index'
    else
      @current_orders = Order.find_current
      @other_orders = @current_orders.reject{|order| order == @order}
      # Load order article data...
      @articles_by_category = @order.get_articles
      # save results of earlier orders in array
      ordered_articles = Array.new
      @group_order = @order.group_orders.find(:first, :conditions => "order_group_id = #{@order_group.id}", :include => :group_order_articles)       
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
        @availableFunds = @order_group.getAvailableFunds(@group_order)
      else
        @version = 0
        @availableFunds = @order_group.getAvailableFunds
      end
      
      # load prices ....
      @price = Array.new; @unit = Array.new; 
      @others_quantity = Array.new; @quantity = Array.new; @quantity_result = Array.new; @used_quantity = Array.new; @unused_quantity = Array.new
      @others_tolerance = Array.new; @tolerance = Array.new; @tolerance_result = Array.new; @used_tolerance = Array.new; @unused_tolerance = Array.new
      i = 0;
      @articles_by_category.each do |category, order_articles|
        for order_article in order_articles
          # price/unit size
          @price[i] = order_article.article.gross_price
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
  end
  
  # Update changes to a current order.
  def saveOrder
    order = Order.find(params[:id], :include => [:supplier, :order_articles])
    if (!order.current?)
      flash[:error] = ERROR_ALREADY_FINISHED
      redirect_to :action => 'index'
    elsif !(order_group = @current_user.find_ordergroup)
      flash[:error] = ERROR_NO_ORDERGROUP
      redirect_to :controller => 'index'
    elsif (params[:total_balance].to_i < 0)
      flash[:error] = ERROR_INSUFFICIENT_FUNDS
      redirect_to :action => 'order'
    elsif (ordered = params[:ordered])
       begin
         Order.transaction do
           # Create group order if necessary...
           if (groupOrder = order.group_orders.find(:first, :conditions => "order_group_id = #{order_group.id}", :include => [:group_order_articles]))
              if (params[:version].to_i != groupOrder.lock_version) # check for conflicts well ahead
                raise ActiveRecord::StaleObjectError
              end
           else
              groupOrder = GroupOrder.new(:order_group => order_group, :order => order, :updated_by => @current_user, :price => 0)   
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
              groupOrderArticle.updateQuantities(quantity.to_i, tolerance.to_i)
              # Add to new list of GroupOrderArticles:
              newGroupOrderArticles.push(groupOrderArticle)
           end
           groupOrder.group_order_articles = newGroupOrderArticles
           groupOrder.updatePrice
           groupOrder.updated_by = @current_user
           groupOrder.save!
           order.updateQuantities
           order.save!
         end         
         flash[:notice] = MSG_ORDER_UPDATED
       rescue ActiveRecord::StaleObjectError
         flash[:error] = ERROR_UPDATE_CONFLICT
       rescue => exception
         logger.error('Failed to update order: ' + exception.message)
         flash[:error] = ERROR_UPDATE_FAILED
       end
       redirect_to :action => 'my_order_result', :id => order
    end
  end
  
  # Shows the Result for the OrderGroup the current user belongs to
  # this method decides between finished and unfinished orders
  def my_order_result
    @order= Order.find(params[:id])
    @current_orders = Order.find_current #.reject{|order| order == @order}
    if @order.finished?
      @finished= true
      @groupOrderResult= @order.group_order_results.find_by_group_name(@current_user.find_ordergroup.name)
      @order_value= @groupOrderResult.price if @groupOrderResult
      @comments= @order.comments
    else
      @group_order = @order.group_orders.find_by_order_group_id(@current_user.find_ordergroup.id)
      @order_value= @group_order.price if @group_order
    end
  end
  
  # Shows all Orders of the Ordergroup
  # if selected, it shows all orders of the foodcoop
  def myOrders
    @orderGroup = @current_user.find_ordergroup
    unless params[:show_all] == "1"
      # get only orders belonging to the ordergroup
      @finishedOrders = @orderGroup.findExpiredOrders + @orderGroup.findFinishedNotBooked  
      @bookedOrders = GroupOrderResult.paginate :page => params[:page], :per_page => 10,
                                                :include => :order,
                                                :conditions => ["group_order_results.group_name = ? AND group_order_results.order_id = orders.id AND orders.finished = ? AND orders.booked = ? ", @orderGroup.name, true, true],
                                                :order => "orders.ends DESC"
    else
      # get all orders, take care of different models in @finishedOrders
      @show_all = true
      @finishedOrders = Order.find_finished
      @bookedOrders = Order.paginate_all_by_booked true, :page => params[:page], :per_page => 10, :order => 'ends desc'
    end
    
    respond_to do |format|
      format.html # myOrders.haml
      format.js do
        render :update do |page|
          page.replace_html 'bookedOrders', :partial => "bookedOrders"
        end
      end
    end
  end
  
  # sends a form for adding a new comment
  def newComment
    @order = Order.find(params[:id])
    render :update do |page|
      page.replace_html 'newComment', :partial => 'shared/newComment', :object => @order
      page["newComment"].show
    end
  end
  
  # adds a Comment to the Order
  def addComment
    @order = Order.find(params[:id])
    @comment = Comment.new(params[:comment])
    @comment.user = @current_user
    if @comment.title.length > 3 && @order.comments << @comment
      flash[:notice] =  _("Comment has been created.")
      redirect_to :action => 'my_order_result', :id => @order 
    else
      flash[:error] = _("The comment has not been saved. Check the title and try again.")
      redirect_to :action => 'my_order_result', :id => @order
    end
  end

  private
  
    # Returns true if @current_user is member of an OrderGroup.
    # Used as a :before_filter by OrderingController.
    def ensureOrderGroupMember
      !@current_user.find_ordergroup.nil?
    end    

end
