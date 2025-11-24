class MultiOrdersController < ApplicationController
  include InvoiceHelper
  before_action :set_multi_order, only: [:generate_ordergroup_invoices]

  def create
    orders = Order.where(id: multi_order_params[:order_ids_for_multi_order])

    unclosed_orders = orders.select { |order| order.closed? == false }
    multi_orders = orders.select { |order| order.multi_order_id.present? }
    invoiced_orders = orders.select { |order| order.group_orders.map(&:group_order_invoice).compact.present? }

    if multi_order_params[:multi_order_ids_for_multi_multi_order].present?
      msg = I18n.t('multi_orders.create.no_multi_multi')
      flash[:alert] = msg
      respond_to do |format|
        format.js
        format.html { redirect_to finance_order_index_path }
      end
      return
    end
    if multi_orders.any? || unclosed_orders.any?
      msg = I18n.t('multi_orders.create.invalid_orders')
      flash[:alert] = msg
      respond_to do |format|
        format.js
        format.html { redirect_to finance_order_index_path }
      end
      return
    end
    if invoiced_orders.any?
      msg = I18n.t('multi_orders.create.merge_not_possible_invoices_present')
      flash[:alert] = msg
      respond_to do |format|
        format.js
        format.html { redirect_to finance_order_index_path }
      end
      return
    end
    begin
      @multi_order = MultiOrder.new
      @multi_order.orders = orders
      @multi_order.ends = orders.map(&:ends).max
      @multi_order.save!
      suppliers = orders.map(&:supplier).map(&:name).join(', ')
      msg = I18n.t('multi_orders.create.success', suppliers: suppliers)
      respond_to do |format|
        flash[:notice] = msg
        format.js
        format.html { redirect_to finance_order_index_path }
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = t('errors.general_msg', msg: e.message)
      respond_to do |format|
        format.js
        format.html { redirect_to finance_order_index_path }
      end
    end
  end

  def destroy
    @multi_order = MultiOrder.find(params[:id])
    if @multi_order.ordergroup_invoices.any?
      flash[:alert] = I18n.t('multi_orders.destroy.invoices_left')
    else
      @multi_order.destroy
      redirect_to finance_order_index_path
    end
  end

  def generate_ordergroup_invoices
    @multi_order.group_orders.group_by(&:ordergroup_id).each_value do |group_orders|
      OrdergroupInvoice.create!(group_orders: group_orders)
    end
    redirect_to finance_order_index_path, notice: t('finance.balancing.close.notice')
  rescue StandardError => e
    redirect_to finance_order_index_path, alert: t('errors.general_msg', msg: e.message)
  end

  def collective_direct_debit
    if foodsoft_sepa_ready?
      case params[:mode]
      when 'all'
        multi_group_orders = MultiGroupOrder.where(multi_order_id: params[:id])
      when 'selected'
        # TODO: !!! params and javascript
        multi_group_orders = MultiGroupOrder.where(id: params[:multi_group_order_ids])
      else
        redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: '')
      end
      process_sepa_export(multi_group_orders)
    else
      respond_to do |format|
        format.html do
          redirect_to finance_order_index_path, alert: I18n.t('activerecord.attributes.group_order_invoice.links.sepa_not_ready')
        end
        format.xml do
          redirect_to finance_order_index_path, alert: I18n.t('activerecord.attributes.group_order_invoice.links.sepa_not_ready')
        end
        format.js
      end
    end
  end

  private

  def process_sepa_export(multi_group_orders)
    @multi_order = MultiOrder.find(params[:id])
    ordergroups = multi_group_orders.flat_map(&:group_orders).map(&:ordergroup)

    export_allowed = ordergroups.map(&:sepa_possible?).exclude?(false) && multi_group_orders.map { |go| go.ordergroup_invoice.present? }.exclude?(false)
    multi_group_orders.map { |mgo| mgo.id if mgo.ordergroup_invoice.present? }

    sepa_possible_ordergroup_names = ordergroups.map { |ordergroup| ordergroup.name if ordergroup.sepa_possible? }.compact_blank
    sepa_not_possible_ordergroup_names = ordergroups.map(&:name) - sepa_possible_ordergroup_names

    if export_allowed && multi_group_orders.present?
      generate_and_send_sepa_export(multi_group_orders, sepa_not_possible_ordergroup_names)
    else
      respond_to do |format|
        format.html do
          redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: '')
        end
        format.xml do
          render json: { error: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: '') }
        end
        format.js
      end
    end
  end

  def generate_and_send_sepa_export(multi_group_orders, sepa_not_possible_ordergroup_names)
    respond_to do |format|
      format.html do
        collective_debit = OrderCollectiveDirectDebitXml.new(multi_group_orders)
        send_data collective_debit.xml_string, filename: @order.name + '_' + I18n.t('multi_orders.collective_direct_debit.filename_suffix') + '.xml', type: 'text/xml'
        multi_group_orders.map(&:ordergroup_invoice).each(&:mark_sepa_downloaded)
      rescue StandardError => e
        multi_group_orders.map(&:ordergroup_invoice).each(&:unmark_sepa_downloaded)
        redirect_to finance_order_index_path, alert: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: e.message)
      end
      format.xml do
        multi_group_orders.map(&:ordergroup_invoice).each(&:mark_sepa_downloaded)
        collective_debit = OrderCollectiveDirectDebitXml.new(multi_group_orders)
        send_data collective_debit.xml_string, filename: @multi_order.name + '_' + I18n.t('multi_orders.collective_direct_debit.filename_suffix') + '.xml', type: 'text/xml'
      rescue StandardError => e
        multi_group_orders.map(&:ordergroup_invoice).each(&:unmark_sepa_downloaded)
        render json: { error: I18n.t('orders.collective_direct_debit.alert', ordergroup_names: sepa_not_possible_ordergroup_names.join(', '), error: e.message) }
      end
      format.js
    end
  end

  def set_multi_order
    @multi_order = MultiOrder.find(params[:id])
  end

  def multi_order_params
    params.permit(:id, :foodcoop, order_ids_for_multi_order: [], multi_order_ids_for_multi_multi_order: [])
  end
end
