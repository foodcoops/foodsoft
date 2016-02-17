class Finance::InvoicesController < ApplicationController

  def index
    @invoices = Invoice.includes(:supplier, :delivery, :order).order('date DESC').page(params[:page]).per(@per_page)
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new :supplier_id => params[:supplier_id],
                           :delivery_id => params[:delivery_id],
                           :order_id => params[:order_id]
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save
      flash[:notice] = I18n.t('finance.create.notice')
      if @invoice.order
        # Redirect to balancing page
        redirect_to new_finance_order_url(order_id: @invoice.order.id)
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
end
