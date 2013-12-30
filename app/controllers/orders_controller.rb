# encoding: utf-8
#
# Controller for managing orders, i.e. all actions that require the "orders" role.
# Normal ordering actions of members of order groups is handled by the OrderingController.
class OrdersController < ApplicationController
  
  before_filter :authenticate_orders
  
  # List orders
  def index
    @open_orders = Order.open.includes(:supplier)
    @orders_in_progress = Order.finished_not_closed.includes(:supplier)
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
    @orders = Order.closed.page(params[:page]).per(@per_page).includes(:supplier).order(sort)
  end

  # Gives a view for the results to a specific order
  # Renders also the pdf
  def show
    @order= Order.find(params[:id])

    respond_to do |format|
      format.html
      format.js do
        @partial = case params[:view]
                     when 'default' then "articles"
                     when 'groups'then 'shared/articles_by_groups'
                     when 'articles'then 'shared/articles_by_articles'
                     else 'articles'
                   end
        render :layout => false
      end
      format.pdf do
        pdf = case params[:document]
                when 'groups' then OrderByGroups.new(@order)
                when 'articles' then OrderByArticles.new(@order)
                when 'fax' then OrderFax.new(@order)
                when 'matrix' then OrderMatrix.new(@order)
              end
        send_data pdf.to_pdf, filename: pdf.filename, type: 'application/pdf'
      end
      format.text do
        send_data text_fax_template, filename: @order.name+'.txt', type: 'text/plain'
      end
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
    @order.created_by = current_user
    if @order.save
      flash[:notice] = I18n.t('orders.create.notice')
      redirect_to @order
    else
      logger.debug "[debug] order errors: #{@order.errors.messages}"
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
      flash[:notice] = I18n.t('orders.update.notice')
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
    redirect_to order, notice: I18n.t('orders.finish.notice')
  rescue => error
    redirect_to orders_url, alert: I18n.t('errors.general_msg', :msg => error.message)
  end

  # ajax add article
  def add_article
    @order = Order.find(params[:id])
    @order_article = @order.order_articles.where(:article_id => params[:article_id]).includes(:article).first
    # we need to create the order article if it's not part of the current order
    if @order_article.nil?
      @order_article = @order.order_articles.build({order: @order, article_id: params[:article_id]})
      @order_article.save!
    end
  end

  def receive
    @order = Order.find(params[:id])
    unless request.post?
      @order_articles = @order.order_articles.ordered.includes(:article)
    else
      flash[:notice] = "Order received: " + update_order_amounts
      redirect_to @order
    end
  end
  
  def receive_on_order_article_update # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])
    
    render :layout => false
  end

  protected
  
  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  # TODO move to text template
  def text_fax_template
    supplier = @order.supplier
    contact = FoodsoftConfig[:contact].symbolize_keys
    text = I18n.t('orders.fax.heading', :name => FoodsoftConfig[:name])
    text += "\n#{Supplier.human_attribute_name(:customer_number)}: #{supplier.customer_number}" unless supplier.customer_number.blank?
    text += "\n" + I18n.t('orders.fax.delivery_day')
    text += "\n\n#{supplier.name}\n#{supplier.address}\n#{Supplier.human_attribute_name(:fax)}: #{supplier.fax}\n\n"
    text += "****** " + I18n.t('orders.fax.to_address') + "\n\n"
    text += "#{FoodsoftConfig[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += "****** " + I18n.t('orders.fax.articles') + "\n\n"
    text += I18n.t('orders.fax.number') + "   " + I18n.t('orders.fax.amount') + "   " + I18n.t('orders.fax.name') + "\n"
    # now display all ordered articles
    @order.order_articles.ordered.all(:include => [:article, :article_price]).each do |oa|
      number = oa.article.order_number
      (8 - number.size).times { number += " " }
      quantity = oa.units_to_order.to_i.to_s
      quantity = " " + quantity if quantity.size < 2
      text += "#{number}   #{quantity}    #{oa.article.name}\n"
    end
    text
  end

  def update_order_amounts
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
          unless oa.units_received.blank?
            cunits[0] += oa.units_received * oa.article.unit_quantity
            oacounts = oa.redistribute oa.units_received * oa.price.unit_quantity, rest_to
            oacounts.each_with_index {|c,i| cunits[i+1]+=c; counts[i+1]+=1 if c>0 }
          end
          oa.save!
        end
      end
    end
    notice = " #{counts.shift} articles (#{cunits.shift} units) updated"
    notice += ", #{counts.shift} (#{cunits.shift}) using tolerance" if params[:rest_to_tolerance]
    notice += ", #{counts.shift} (#{cunits.shift}) go to stock if foodsoft would support that" if params[:rest_to_stock]
    notice += ", #{counts.shift} (#{cunits.shift}) left over"
  end

end
