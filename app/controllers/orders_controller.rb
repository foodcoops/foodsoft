# encoding: utf-8
#
# Controller for managing orders, i.e. all actions that require the "orders" role.
# Normal ordering actions of members of order groups is handled by the OrderingController.
class OrdersController < ApplicationController
  
  before_filter :authenticate_orders
  
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
    @orders = Order.page(params[:page]).per(@per_page).order(sort).where("state != 'open'").includes(:supplier)
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
  end
  
  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  def text_fax_template
    order = Order.find(params[:id])
    supplier = order.supplier
    contact = FoodsoftConfig[:contact].symbolize_keys
    text = I18n.t('orders.fax.heading', :name => FoodsoftConfig[:name])
    text += "\n" + I18n.t('orders.fax.customer_number') + ': #{supplier.customer_number}' unless supplier.customer_number.blank?
    text += "\n" + I18n.t('orders.fax.delivery_day')
    text += "\n\n#{supplier.name}\n#{supplier.address}\n" + I18n.t('simple_form.labels.supplier.fax') + ": #{supplier.fax}\n\n"
    text += "****** " + I18n.t('orders.fax.to_address') + "\n\n"
    text += "#{FoodsoftConfig[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += "****** " + I18n.t('orders.fax.articles') + "\n\n"
    text += I18n.t('orders.fax.number') + "   " + I18n.t('orders.fax.amount') + "   " + I18n.t('orders.fax.name') + "\n"
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
end
