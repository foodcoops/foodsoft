class Finance::FinancialLinksController < Finance::BaseController
  before_action :find_financial_link, except: [:create, :incomplete]

  def show
    @items = @financial_link.bank_transactions.map do |bt|
      {
        date: bt.date,
        type: t('activerecord.models.bank_transaction'),
        description: bt.text,
        amount: bt.amount,
        link_to: finance_bank_transaction_path(bt),
        remove_path: remove_bank_transaction_finance_link_path(@financial_link, bt)
      }
    end
    @items += @financial_link.financial_transactions.map do |ft|
      {
        date: ft.created_on,
        type: t('activerecord.models.financial_transaction'),
        description: "#{ft.ordergroup_name}: #{ft.note}",
        amount: ft.amount,
        link_to: finance_group_transactions_path(ft.ordergroup),
        remove_path: remove_financial_transaction_finance_link_path(@financial_link, ft)
      }
    end
    @items += @financial_link.invoices.includes(:supplier).map do |invoice|
      {
        date: invoice.date || invoice.created_at,
        type: t('activerecord.models.invoice'),
        description: "#{invoice.supplier.name}: #{invoice.number}",
        amount: invoice.amount,
        link_to: finance_invoice_path(invoice),
        remove_path: remove_invoice_finance_link_path(@financial_link, invoice)
      }
    end
    @items.sort_by! { |item| item[:date] }
  end

  def create
    @financial_link = FinancialLink.new
    if params[:bank_transaction] then
      bank_transaction = BankTransaction.find(params[:bank_transaction])
      bank_transaction.update_attribute :financial_link, @financial_link
    end
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def incomplete
    @financial_links = FinancialLink.incomplete
  end

  def index_bank_transaction
    @bank_transactions = BankTransaction.without_financial_link
  end

  def add_bank_transaction
    bank_transaction = BankTransaction.find(params[:bank_transaction])
    bank_transaction.update_attribute :financial_link, @financial_link
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def remove_bank_transaction
    bank_transaction = BankTransaction.find(params[:bank_transaction])
    bank_transaction.update_attribute :financial_link, nil
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def index_financial_transaction
    @financial_transactions = FinancialTransaction.without_financial_link.includes(:financial_transaction_type, :ordergroup)
  end

  def add_financial_transaction
    financial_transaction = FinancialTransaction.find(params[:financial_transaction])
    financial_transaction.update_attribute :financial_link, @financial_link
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def remove_financial_transaction
    financial_transaction = FinancialTransaction.find(params[:financial_transaction])
    financial_transaction.update_attribute :financial_link, nil
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def index_invoice
    @invoices = Invoice.without_financial_link.includes(:supplier)
  end

  def add_invoice
    invoice = Invoice.find(params[:invoice])
    invoice.update_attribute :financial_link, @financial_link
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

  def remove_invoice
    invoice = Invoice.find(params[:invoice])
    invoice.update_attribute :financial_link, nil
    redirect_to finance_link_url(@financial_link), notice: t('.notice')
  end

protected

  def find_financial_link
    @financial_link = FinancialLink.find(params[:id])
  end

end
