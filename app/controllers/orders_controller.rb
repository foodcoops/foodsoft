#
# Controller for managing orders, i.e. all actions that require the "orders" role.
# Normal ordering actions of members of order groups is handled by the OrderingController.
class OrdersController < ApplicationController
  include Concerns::SendOrderPdf

  before_action :authenticate_pickups_or_orders
  before_action :authenticate_orders,
                except: %i[receive receive_on_order_article_create receive_on_order_article_update show]
  before_action :remove_empty_article, only: %i[create update]

  # List orders
  def index
    @open_orders = Order.open.includes(:supplier)
    @finished_orders = Order.finished_not_closed.includes(:supplier)
    @per_page = 15
    sort = if params['sort']
             case params['sort']
             when 'supplier'         then 'suppliers.name, ends DESC'
             when 'pickup'           then 'pickup DESC'
             when 'ends'             then 'ends DESC'
             when 'supplier_reverse' then 'suppliers.name DESC'
             when 'ends_reverse'     then 'ends'
             end
           else
             'ends DESC'
           end
    @suppliers = Supplier.having_articles.order('suppliers.name')
    @orders = Order.closed.includes(:supplier).reorder(sort).page(params[:page]).per(@per_page)
  end

  # Gives a view for the results to a specific order
  # Renders also the pdf
  def show
    @order = Order.find(params[:id])
    @view = (params[:view] || 'default').gsub(/[^-_a-zA-Z0-9]/, '')
    @partial = case @view
               when 'default'  then 'articles'
               when 'groups'   then 'shared/articles_by/groups'
               when 'articles' then 'shared/articles_by/articles'
               else 'articles'
               end

    respond_to do |format|
      format.html
      format.js do
        render layout: false
      end
      format.pdf do
        send_order_pdf @order, params[:document]
      end
      format.csv do
        send_data OrderCsv.new(@order).to_csv, filename: @order.name + '.csv', type: 'text/csv'
      end
      format.text do
        send_data OrderTxt.new(@order).to_txt, filename: @order.name + '.txt', type: 'text/plain'
      end
    end
  end

  # Page to create a new order.
  def new
    if params[:order_id]
      old_order = Order.find(params[:order_id])
      @order = Order.new(supplier_id: old_order.supplier_id).init_dates
      @order.article_ids = old_order.article_ids
    else
      @order = Order.new(supplier_id: params[:supplier_id]).init_dates
    end
  rescue StandardError => e
    redirect_to orders_url, alert: t('errors.general_msg', msg: e.message)
  end

  # Page to edit an exsiting order.
  # editing finished orders is done in FinanceController
  def edit
    @order = Order.includes(:articles).find(params[:id])
  end

  # Save a new order.
  # order_articles will be saved in Order.article_ids=()
  def create
    @order = Order.new(params[:order])
    @order.created_by = current_user
    @order.updated_by = current_user
    if @order.save
      flash[:notice] = I18n.t('orders.create.notice')
      redirect_to @order
    else
      logger.debug "[debug] order errors: #{@order.errors.messages}"
      render action: 'new'
    end
  end

  # Update an existing order.
  def update
    @order = Order.find params[:id]
    if @order.update params[:order].merge(updated_by: current_user)
      flash[:notice] = I18n.t('orders.update.notice')
      redirect_to action: 'show', id: @order
    else
      render action: 'edit'
    end
  end

  # Delete an order.
  def destroy
    Order.find(params[:id]).destroy
    redirect_to action: 'index'
  end

  # Finish a current order.
  def finish
    order = Order.find(params[:id])
    order.finish!(@current_user)
    redirect_to order, notice: I18n.t('orders.finish.notice')
  rescue StandardError => e
    redirect_to orders_url, alert: I18n.t('errors.general_msg', msg: e.message)
  end

  # Send a order to the supplier.
  def send_result_to_supplier
    order = Order.find(params[:id])
    order.send_to_supplier!(@current_user)
    redirect_to order, notice: I18n.t('orders.send_to_supplier.notice')
  rescue StandardError => e
    redirect_to order, alert: I18n.t('errors.general_msg', msg: e.message)
  end

  def receive
    @order = Order.find(params[:id])
    if request.post?
      Order.transaction do
        s = update_order_amounts
        @order.update_attribute(:state, 'received') if @order.state != 'received'

        flash[:notice] = (s ? I18n.t('orders.receive.notice', msg: s) : I18n.t('orders.receive.notice_none'))
      end
      NotifyReceivedOrderJob.perform_later(@order)
      if current_user.role_orders? || current_user.role_finance?
        redirect_to @order
      elsif current_user.role_pickups?
        redirect_to pickups_path
      else
        redirect_to receive_order_path(@order)
      end
    else
      @order_articles = @order.order_articles.ordered_or_member.includes(:article_version).order('article_versions.order_number, article_versions.name')
    end
  end

  def receive_on_order_article_create # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])
    render layout: false
  end

  def receive_on_order_article_update # See publish/subscribe design pattern in /doc.
    @order_article = OrderArticle.find(params[:order_article_id])
    render layout: false
  end

  protected

  def update_order_amounts
    return unless params[:order_articles]

    # where to leave remainder during redistribution
    rest_to = []
    rest_to << :tolerance if params[:rest_to_tolerance]
    rest_to << :stock if params[:rest_to_stock]
    rest_to << nil
    # count what happens to the articles:
    #   changed, rest_to_tolerance, rest_to_stock, left_over
    counts = [0] * 4
    cunits = [0] * 4
    # This was once wrapped in a transaction, but caused
    # "MySQL lock timeout exceeded" errors. It's ok to do
    # this article-by-article anway.
    params[:order_articles].each do |oa_id, oa_params|
      next if oa_params.blank?

      oa = OrderArticle.find(oa_id)
      # update attributes; don't use update_attribute because it calls save
      # which makes received_changed? not work anymore
      oa.attributes = oa_params
      if oa.units_received_changed?
        counts[0] += 1
        if oa.units_received.present?
          units_received = oa.article_version.convert_quantity(oa.units_received,
                                                               oa.article_version.supplier_order_unit, oa.article_version.group_order_unit)
          cunits[0] += units_received
          oacounts = oa.redistribute units_received, rest_to
          oacounts.each_with_index do |c, i|
            cunits[i + 1] += c
            counts[i + 1] += 1 if c > 0
          end
        end
      end
      oa.save!
    end
    return nil if counts[0] == 0

    notice = []
    notice << I18n.t('orders.update_order_amounts.msg1', count: counts[0], units: cunits[0])
    if params[:rest_to_tolerance]
      notice << I18n.t('orders.update_order_amounts.msg2', count: counts[1],
                                                           units: cunits[1])
    end
    notice << I18n.t('orders.update_order_amounts.msg3', count: counts[2], units: cunits[2]) if params[:rest_to_stock]
    if counts[3] > 0 || cunits[3] > 0
      notice << I18n.t('orders.update_order_amounts.msg4', count: counts[3],
                                                           units: cunits[3])
    end
    notice.join(', ')
  end

  def remove_empty_article
    params[:order][:article_ids].reject!(&:blank?) if params[:order] && params[:order][:article_ids]
  end
end
