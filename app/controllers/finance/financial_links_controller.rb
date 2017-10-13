class Finance::FinancialLinksController < Finance::BaseController

  def show
    @financial_link = FinancialLink.find(params[:id])

    @items = @financial_link.financial_transactions.map do |ft|
      {
        date: ft.created_on,
        type: t('activerecord.models.financial_transaction'),
        description: "#{ft.ordergroup.name}: #{ft.note}",
        amount: ft.amount,
        link_to: finance_ordergroup_transactions_path(ft.ordergroup)
      }
    end
    @items += @financial_link.invoices.map do |invoice|
      {
        date: invoice.date || invoice.created_at,
        type: t('activerecord.models.invoice'),
        description: "#{invoice.supplier.name}: #{invoice.number}",
        amount: invoice.amount,
        link_to: finance_invoice_path(invoice)
      }
    end
    @items.sort_by! { |item| item[:date] }
  end

end
