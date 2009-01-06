# Controller for managing orders, i.e. all actions that require the "orders" role.
# Normal ordering actions of members of order groups is handled by the OrderingController.
class OrdersController < ApplicationController
  # Security
  before_filter :authenticate_orders
  verify :method => :post, :only => [:finish, :create, :update, :destroy, :setAllBooked], :redirect_to => { :action => :index }
  
  # Define layout exceptions for PDF actions:
  layout "application", :except => [:faxPdf, :matrixPdf, :articlesPdf, :groupsPdf]
  
  # List orders
  def index
    @current_orders = Order.find_current
    @per_page = 15
    if params['sort']
      sort = case params['sort']
               when "supplier"  then "suppliers.name, ends DESC"
               when "ends"   then "ends DESC"
               when "supplier_reverse"  then "suppliers.name DESC, ends DESC"
               when "ends_reverse"   then "ends"
               end
    else
      sort = "ends DESC"
    end
    @orders = Order.paginate :page => params[:page], :per_page => @per_page, 
                             :order => sort, :conditions => ['ends < ? OR starts > ? OR finished = ?', Time.now, Time.now, true],
                             :include => :supplier
    
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'orders_table', :partial => "list"
        end
      end
    end
  end

  # Gives a view for the results to a specific order
  def show
    @order= Order.find(params[:id])
    unless @order.finished?
      @order_articles= @order.get_articles
      @group_orders= @order.group_orders
    else
      @finished= true
      @order_articles= @order.order_article_results
      @group_orders= @order.group_order_results
      @comments= @order.comments
      partial = case params[:view]
        when 'normal' then "showResult"
        when 'groups'then 'showResult_groups'
        when 'articles'then 'showResult_articles'
      end
      render :partial => partial if partial
    end
  end

  # Page to create a new order.
  def new
    @supplier = Supplier.find(params[:id])
    @order = @supplier.orders.build :ends => 4.days.from_now
    @template_orders = Order.find_all_by_supplier_id_and_finished(@supplier.id, true, :limit => 3, :order => 'starts DESC', :include => "order_article_results")
  end

  # Save a new order.
  # order_articles will be saved in Order.article_ids=()
  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = _("The order has been created successfully.")
      redirect_to :action => 'show', :id => @order
    else
      render :action => 'new'
    end
  end

  # Page to edit an exsiting order.
  # editing finished orders is done in FinanceController
  def edit
    @order = Order.find(params[:id], :include => :articles)
  end

  # Update an existing order.
  def update
    @order = Order.find params[:id]
    if @order.update_attributes params[:order]
      flash[:notice] = _("The order has been updated.")
      redirect_to :action => 'show', :id => @order
    else
      render :action => 'edit'
    end
    @order.updateAllGroupOrders #important if ordered articles has been removed
  end

  # Delete an order.
  def destroy
    Order.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  # Finish a current order.
  def finish
    order = Order.find(params[:id])
    order.finish(@current_user)
    flash[:notice] = _("The order has been finished successfully.")
    redirect_to :action => 'show', :id => order
  end
  
  # Renders the groups-orderd PDF.
  def groupsPdf
    @order = Order.find(params[:id])
    @options_for_rfpdf ||= {}
    @options_for_rfpdf[:file_name] = "#{Date.today}_#{@order.name}_GruppenSortierung.pdf"
  end
  
  # Renders the articles-orderd PDF.
  def articlesPdf
    @order = Order.find(params[:id])
    @options_for_rfpdf ||= {}
    @options_for_rfpdf[:file_name] = "#{Date.today}_#{@order.name}_ArtikelSortierung.pdf"
  end
  
  # Renders the fax PDF.
  def faxPdf
    @order = Order.find(params[:id])
    @options_for_rfpdf ||= {}
    @options_for_rfpdf[:file_name] = "#{Date.today}_#{@order.name}_FAX.pdf"
  end
  
  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  def text_fax_template
    order = Order.find(params[:id])
    supplier = order.supplier
    contact = APP_CONFIG[:contact].symbolize_keys
    text = _("Order for") + " #{APP_CONFIG[:name]}"
    text += "\n" + _("Customer number") + ": #{supplier.customer_number}" unless supplier.customer_number.blank?
    text += "\n" + _("Delivery date") + ": "
    text += "\n\n#{supplier.name}\n#{supplier.address}\nFAX: #{supplier.fax}\n\n"
    text += "****** " + _("Shipping address") + "\n\n"
    text += "#{APP_CONFIG[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += "****** " + _("Articles") + "\n\n"
    text += _("Number") + "  " + _("Quantity") + "  " + _("Name") + "\n"
    # now display all ordered articles
    order.order_article_results.each do |article|
      text += article.order_number.blank? ? "        " : "#{article.order_number}  "
      quantity = article.units_to_order.to_i.to_s
      quantity = " " + quantity if quantity.size < 2
      text += "#{quantity}     #{article.name}\n"
    end
    send_data text,
                :type => 'text/plain; charset=utf-8; header=present',
                :disposition => "attachment; filename=#{order.name}"
  end
  
  # Renders the matrix PDF.
  def matrixPdf
    @order = Order.find(params[:id])
    @options_for_rfpdf ||= {}
    @options_for_rfpdf[:file_name] = "#{Date.today}_#{@order.name}_Matrix.pdf"
  end

  # sends a form for adding a new comment
  def newComment
    @order = Order.find(params[:id])
    render :update do |page|
      page.replace_html 'newComment', :partial => 'shared/newComment', :object => @order
    end
  end
  
  # adds a Comment to the Order
  def addComment
    @order = Order.find(params[:id])
    @comment = Comment.new(params[:comment])
    @comment.user = @current_user
    if @comment.title.length > 3 && @order.comments << @comment
      flash[:notice] = _("Comment has been created.")
      redirect_to :action => 'show', :id => @order 
    else
      flash[:error] = _("The comment has not been saved. Check the title and try again.")
      redirect_to :action => 'show', :id => @order
    end
  end
end