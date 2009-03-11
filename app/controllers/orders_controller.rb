# Controller for managing orders, i.e. all actions that require the "orders" role.
# Normal ordering actions of members of order groups is handled by the OrderingController.
class OrdersController < ApplicationController
  
  before_filter :authenticate_orders
  
  # Define layout exceptions for PDF actions:
  layout "application", :except => [:faxPdf, :matrixPdf, :articlesPdf, :groupsPdf]
  prawnto :prawn => { :page_size => 'A4' }
  
  # List orders
  def index
    @open_orders = Order.open
    @per_page = 15
    if params['sort']
      sort = case params['sort']
               when "supplier"  then "suppliers.name, ends DESC"
               when "ends"   then "ends DESC"
               when "supplier_reverse"  then "suppliers.name DESC"
               when "ends_reverse"   then "ends"
               end
    else
      sort = "ends DESC"
    end
    @orders = Order.paginate :page => params[:page], :per_page => @per_page, 
                             :order => sort, :conditions => "state != 'open'",
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
  # Renders also the pdf
  def show
    @order= Order.find(params[:id])

    if params[:view]    # Articles-list will be replaced
      partial = case params[:view]
        when 'normal' then "articles"
        when 'groups'then 'shared/articles_by_groups'
        when 'articles'then 'shared/articles_by_articles'
      end
      render :partial => partial, :locals => {:order => @order} if partial
    end
  end

  # Page to create a new order.
  def new
    @order = Order.new :ends => 4.days.from_now, :supplier_id => params[:supplier_id]
  end

  # Save a new order.
  # order_articles will be saved in Order.article_ids=()
  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Die Bestellung wurde erstellt."
      redirect_to @order
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
      flash[:notice] = "Die Bestellung wurde aktualisiert."
      redirect_to :action => 'show', :id => @order
    else
      render :action => 'edit'
    end
  end

  # Delete an order.
  def destroy
    Order.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  # Finish a current order.
  def finish
    order = Order.find(params[:id])
    order.finish!(@current_user)
    call_rake "foodsoft:notify_order_finished", :order_id => order.id
    flash[:notice] = "Die Bestellung wurde beendet."
    redirect_to order
  end
  
  # Renders the groups-orderd PDF.
  def groupsPdf
    @order = Order.find(params[:id])
    prawnto :filename => "#{Date.today}_#{@order.name}_GruppenSortierung.pdf"
  end
  
  # Renders the articles-orderd PDF.
  def articlesPdf
    @order = Order.find(params[:id])
    prawnto :filename => "#{Date.today}_#{@order.name}_ArtikelSortierung.pdf",
            :prawn => { :left_margin => 48,
                        :right_margin => 48,
                        :top_margin => 48,
                        :bottom_margin => 48 }
  end
  
  # Renders the fax PDF.
  def faxPdf
    @order = Order.find(params[:id])
    prawnto :filename => "#{Date.today}_#{@order.name}_FAX.pdf"
  end
  
  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  def text_fax_template
    order = Order.find(params[:id])
    supplier = order.supplier
    contact = APP_CONFIG[:contact].symbolize_keys
    text = "Bestellung für" + " #{APP_CONFIG[:name]}"
    text += "\n" + "Kundennummer" + ": #{supplier.customer_number}" unless supplier.customer_number.blank?
    text += "\n" + "Liefertag" + ": "
    text += "\n\n#{supplier.name}\n#{supplier.address}\nFAX: #{supplier.fax}\n\n"
    text += "****** " + "Versandadresse" + "\n\n"
    text += "#{APP_CONFIG[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += "****** " + "Artikel" + "\n\n"
    text += "Nummer" + "   " + "Menge" + "   " + "Name" + "\n"
    # now display all ordered articles
    order.order_articles.ordered.all(:include => [:article, :article_price]).each do |oa|
      number = oa.article.order_number
      (8 - number.size).times { number += " " }
      quantity = oa.units_to_order.to_i.to_s
      quantity = " " + quantity if quantity.size < 2
      text += "#{number}   #{quantity}    #{oa.article.name}\n"
    end
    send_data text,
                :type => 'text/plain; charset=utf-8; header=present',
                :disposition => "attachment; filename=#{order.name}"
  end
  
  # Renders the matrix PDF.
  def matrixPdf
    @order = Order.find(params[:id])
    prawnto :filename => "#{Date.today}_#{@order.name}_Matrix.pdf"
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
    redirect_to order
  end
end