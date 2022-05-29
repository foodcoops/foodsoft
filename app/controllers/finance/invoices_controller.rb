class Finance::InvoicesController < ApplicationController
  before_action :authenticate_finance_or_invoices

  before_action :find_invoice, only: %i[show edit update destroy]
  before_action :ensure_can_edit, only: %i[edit update destroy]

  def index
    @invoices_all = Invoice.includes(:supplier, :deliveries, :orders).order('date DESC')
    @invoices = @invoices_all.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.js
      format.html { render }
      format.csv do
        send_data InvoicesCsv.new(@invoices_all).to_csv, filename: 'invoices.csv', type: 'text/csv'
      end
    end
  end

  def unpaid
    @suppliers = Supplier.includes(:invoices).where('invoices.paid_on IS NULL').references(:invoices)
  end

  def show; end

  def new
    @invoice = Invoice.new supplier_id: params[:supplier_id]
    @invoice.deliveries << Delivery.find_by_id(params[:delivery_id]) if params[:delivery_id]
    @invoice.orders << Order.find_by_id(params[:order_id]) if params[:order_id]
    fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
  end

  def edit
    fill_deliveries_and_orders_collection @invoice.id, @invoice.supplier_id
  end

  def form_on_supplier_id_change
    fill_deliveries_and_orders_collection params[:invoice_id], params[:supplier_id]
    render layout: false
  end

  def fill_deliveries_and_orders_collection(invoice_id, supplier_id)
    @deliveries_collection = Delivery.where('invoice_id = ? OR (invoice_id IS NULL AND supplier_id = ?)', invoice_id,
                                            supplier_id).order(date: :desc).limit(25)
    @orders_collection = Order.where('invoice_id = ? OR (invoice_id IS NULL AND supplier_id = ?)', invoice_id,
                                     supplier_id).order(ends: :desc).limit(25)
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
      render action: 'new'
    end
  end

  def update
    if @invoice.update(params[:invoice])
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

  def delete_attachment
    attachment = ActiveStorage::Attachment.find(params[:attachment_id])
    attachment.purge_later
    respond_to do |format|
      format.js
    end
  end

  def pay
    unless params[:invoices]
      return redirect_to unpaid_finance_invoices_path, alert: I18n.t('finance.invoices.controller.pay.no_invoices')
    end

    ids = params[:invoices].map(&:to_i)
    invoices = Invoice.includes(:supplier).where(id: ids)

    bank_gateways = BankGateway
                    .includes({ bank_accounts: { supplier_categories: { suppliers: :invoices } } })
                    .where({ invoices: { id: ids } })

    unless bank_gateways.length == 1
      return redirect_to unpaid_finance_invoices_path, alert: I18n.t('finance.invoices.controller.pay.multiple_bank_gateways')
    end

    bank_gateway = bank_gateways.first

    payments = invoices.map do |i|
      {
        instructedAmount: {
          currency: 'EUR',
          amount: i.amount.to_s
        },
        debtorAccount: {
          iban: i.supplier.supplier_category.bank_account.iban
        },
        creditorName: i.supplier.name,
        creditorAccount: {
          iban: i.supplier.iban
        },
        remittanceInformationUnstructured: i.number
      }
    end

    callback_url = callback_finance_bank_gateway_url(bank_gateway)
    user = bank_gateway.unattended_user != current_user && current_user
    location = bank_gateway.connector.pay_and_import_url callback_url, user, { sepaCreditTransferPayments: payments }
    redirect_to location, status: :found
  end

  private

  def find_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Returns true if @current_user can edit the invoice..
  def ensure_can_edit
    return if @invoice.user_can_edit?(current_user)

    deny_access
  end
end
