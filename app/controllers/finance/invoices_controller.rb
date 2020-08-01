class Finance::InvoicesController < ApplicationController
  before_action :authenticate_finance_or_invoices

  before_action :find_invoice, only: [:show, :edit, :update, :destroy]
  before_action :ensure_can_edit, only: [:edit, :update, :destroy]

  def index
    @invoices = Invoice.includes(:supplier, :deliveries, :orders).order('date DESC').page(params[:page]).per(@per_page)
  end

  def unpaid
    @suppliers = Supplier.includes(:invoices).where('invoices.paid_on IS NULL').references(:invoices)
  end

  def show
  end

  def new
    @invoice = Invoice.new :supplier_id => params[:supplier_id]
    @invoice.deliveries << Delivery.find_by_id(params[:delivery_id]) if params[:delivery_id]
    @invoice.orders << Order.find_by_id(params[:order_id]) if params[:order_id]
    fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
  end

  def edit
    fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
  end

  def form_on_supplier_id_change
    fill_deliveries_and_orders_collection params[:invoice_id], params[:supplier_id]
    render :layout => false
  end

  def fill_deliveries_and_orders_collection(invoice_id, supplier_id)
    @deliveries_collection = Delivery.where('invoice_id = ? OR (invoice_id IS NULL AND supplier_id = ?)', invoice_id, supplier_id).order(:date)
    @orders_collection = Order.where('invoice_id = ? OR (invoice_id IS NULL AND supplier_id = ? AND state = ?)', invoice_id, supplier_id, 'finished').order(:ends)
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save
      flash[:notice] = I18n.t('finance.create.notice')
      if @invoice.orders.count == 1 && current_user.role_finance?
        # Redirect to balancing page
        redirect_to new_finance_order_url(order_id: @invoice.orders.first.id)
      else
        redirect_to [:finance, @invoice]
      end
    else
      fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
      render :action => "new"
    end
  end

  def update
    if @invoice.update_attributes(params[:invoice])
      redirect_to [:finance, @invoice], notice: I18n.t('finance.update.notice')
    else
      fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
      render :edit
    end
  end

  def destroy
    @invoice.destroy

    redirect_to finance_invoices_url
  end

  def attachment
    @invoice = Invoice.find(params[:invoice_id])
    type = MIME::Types[@invoice.attachment_mime].first
    filename = "invoice_#{@invoice.id}_attachment.#{type.preferred_extension}"
    send_data(@invoice.attachment_data, :filename => filename, :type => type)
  end

  private

  def find_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Returns true if @current_user can edit the invoice..
  def ensure_can_edit
    unless @invoice.user_can_edit?(current_user)
      deny_access
    end
  end
end
