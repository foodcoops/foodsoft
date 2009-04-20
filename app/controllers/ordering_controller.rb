# Controller for all ordering-actions that are performed by a user who is member of an Ordergroup.
# Management actions that require the "orders" role are handled by the OrdersController.
class OrderingController < ApplicationController
  # Security
  before_filter :ensure_ordergroup_member
  before_filter :ensure_open_order, :only => [:order, :stock_order, :saveOrder]
  
  verify :method => :post, :only => [:saveOrder], :redirect_to => {:action => :index}
  
  # Index page.
  def index
  end
    
  # Edit a current order.
  def order
    redirect_to :action => 'stock_order', :id => @order if @order.stockit?

    # Load order article data...
    @articles_grouped_by_category = @order.articles_grouped_by_category
    # save results of earlier orders in array
    ordered_articles = Array.new
    @group_order = @order.group_orders.find(:first, 
      :conditions => "ordergroup_id = #{@ordergroup.id}", :include => :group_order_articles)

    if @group_order
      # Group has already ordered, so get the results...
      for goa in @group_order.group_order_articles
        ordered_articles[goa.order_article_id] = {:quantity => goa.quantity,
                                                  :tolerance => goa.tolerance,
                                                  :quantity_result => goa.result(:quantity),
                                                  :tolerance_result => goa.result(:tolerance)}
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
    @articles_grouped_by_category.each do |category_name, order_articles|
      for order_article in order_articles
        # price/unit size
        @price[i] = order_article.article.fc_price
        @unit[i] = order_article.article.unit_quantity
        # quantity
        @quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:quantity] : 0)
        @others_quantity[i] = order_article.quantity - @quantity[i]
        @used_quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:quantity_result] : 0)
        # tolerance
        @tolerance[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:tolerance] : 0)
        @others_tolerance[i] = order_article.tolerance - @tolerance[i]
        @used_tolerance[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:tolerance_result] : 0)
        i += 1
      end
    end
  end

  def stock_order
    # Load order article data...
    @articles_grouped_by_category = @order.articles_grouped_by_category
    # save results of earlier orders in array
    ordered_articles = Array.new
    @group_order = @order.group_orders.find(:first,
      :conditions => "ordergroup_id = #{@ordergroup.id}", :include => :group_order_articles)

    if @group_order
      # Group has already ordered, so get the results...
      for goa in @group_order.group_order_articles
        ordered_articles[goa.order_article_id] = {:quantity => goa.quantity,
                                                  :tolerance => goa.tolerance,
                                                  :quantity_result => goa.result(:quantity),
                                                  :tolerance_result => goa.result(:tolerance)}
      end
      @version = @group_order.lock_version
      @availableFunds = @ordergroup.get_available_funds(@group_order)
    else
      @version = 0
      @availableFunds = @ordergroup.get_available_funds
    end

    # load prices ....
    @price = Array.new; @quantity_available = Array.new
    @others_quantity = Array.new; @quantity = Array.new; @quantity_result = Array.new; @used_quantity = Array.new; @unused_quantity = Array.new
    i = 0;
    @articles_grouped_by_category.each do |category_name, order_articles|
      for order_article in order_articles
        # price/unit size
        @price[i] = order_article.article.fc_price
        @quantity_available[i] = order_article.article.quantity_available(@order)
        # quantity
        @quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:quantity] : 0)
        @others_quantity[i] = order_article.quantity - @quantity[i]
        @used_quantity[i] = (ordered_articles[order_article.id] ? ordered_articles[order_article.id][:quantity_result] : 0)
        i += 1
      end
    end
  end
  
  # Update changes to a current order.
  def saveOrder
    if (params[:total_balance].to_i < 0)  #TODO: Better use a real test on sufficiant funds
      flash[:error] = 'Der Bestellwert übersteigt das verfügbare Guthaben.'
      redirect_to :action => 'order'
    elsif (ordered = params[:ordered])
      begin
        Order.transaction do
          # Try to find group_order
          group_order = @order.group_orders.first :conditions => "ordergroup_id = #{@ordergroup.id}",
                                                  :include => [:group_order_articles]
          # Create group order if necessary...
          unless group_order.nil?
            # check for conflicts well ahead
            if (params[:version].to_i != group_order.lock_version)
              raise ActiveRecord::StaleObjectError
            end
          else
            group_order = @ordergroup.group_orders.create!(:order => @order, :updated_by => @current_user, :price => 0)
          end

          # Create/update group_order_articles...
          for order_article in @order.order_articles

            # Find the group_order_article, create a new one if necessary...
            group_order_article = group_order.group_order_articles.detect { |v| v.order_article_id == order_article.id }
            if group_order_article.nil?
              group_order_article = group_order.group_order_articles.create(:order_article_id => order_article.id)
            end

            # Get ordered quantities and update group_order_articles/_quantities...
            quantities = ordered.fetch(order_article.id.to_s, {:quantity => 0, :tolerance => 0})
            group_order_article.update_quantities(quantities[:quantity].to_i, quantities[:tolerance].to_i)

            # Also update results for the order_article
            order_article.update_results!
          end

          group_order.update_price!
          group_order.update_attribute(:updated_by, @current_user)
        end
        flash[:notice] = 'Die Bestellung wurde gespeichert.'
      rescue ActiveRecord::StaleObjectError
        flash[:error] = 'In der Zwischenzeit hat jemand anderes auch bestellt, daher konnte die Bestellung nicht aktualisiert werden.'
      rescue => exception
        logger.error('Failed to update order: ' + exception.message)
        flash[:error] = 'Die Bestellung konnte nicht aktualisiert werden, da ein Fehler auftrat.'
      end
        redirect_to :action => 'my_order_result', :id => @order
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
      format.js { render :partial => "orders", :locals => {:orders => @closed_orders, :pagination => true} }
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
    @ordergroup = @current_user.ordergroup
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
