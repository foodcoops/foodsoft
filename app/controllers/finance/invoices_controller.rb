class Finance::InvoicesController < ApplicationController

  before_filter :ensure_can_edit, only: [:edit, :update, :destroy]

  def index
    @invoices = Invoice.includes(:supplier, :deliveries, :orders).order('date DESC').page(params[:page]).per(@per_page)
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new :supplier_id => params[:supplier_id]
    @invoice.deliveries << Delivery.find_by_id(params[:delivery_id]) if params[:delivery_id]
    @invoice.orders << Order.find_by_id(params[:order_id]) if params[:order_id]
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save
      flash[:notice] = I18n.t('finance.create.notice')
      if @invoice.orders.count == 1
        # Redirect to balancing page
        redirect_to new_finance_order_url(order_id: @invoice.orders.first.id)
      else
        redirect_to [:finance, @invoice]
      end
    else
      render :action => "new"
    end
  end

  def update
    @invoice = Invoice.find(params[:id])

    if @invoice.update_attributes(params[:invoice])
      redirect_to [:finance, @invoice], notice: I18n.t('finance.update.notice')
    else
      render :edit
    end
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy

    redirect_to finance_invoices_url
  end

  def attachment
    @invoice = Invoice.find(params[:invoice_id])
    type = MIME::Types[@invoice.attachment_mime].first
    filename = 'attachment_' + @invoice.id.to_s + '.' + type.preferred_extension
    send_data(@invoice.attachment_data, :filename => filename, :type => type)
  end

  private

  # Returns true if @current_user can edit the invoice..
  def ensure_can_edit
    @invoice = Invoice.find(params[:id])
    unless @invoice.user_can_edit?(current_user)
      deny_access
    end
  end
end
