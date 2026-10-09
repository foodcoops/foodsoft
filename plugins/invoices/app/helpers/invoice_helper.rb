module InvoiceHelper
  SEPA_SEQUENCE_TYPES = {
    FRST: 'First Direct Debit',
    RCUR: 'Recurring Direct Debit',
    OOFF: 'One-time Direct Debit',
    FNAL: 'Final Direct Debit'
  }.freeze

  def foodsoft_sepa_ready?
    FoodsoftConfig[:group_order_invoices]&.[](:iban) && FoodsoftConfig[:group_order_invoices]&.[](:bic) && FoodsoftConfig[:name].present? && FoodsoftConfig[:group_order_invoices]&.[](:creditor_identifier).present?
  end

  def generate_invoice_number(instance, count)
    trailing_number = count.to_s.rjust(4, '0')
    if GroupOrderInvoice.find_by(invoice_number: instance.invoice_date.strftime('%Y%m%d') + trailing_number) || OrdergroupInvoice.find_by(invoice_number: instance.invoice_date.strftime('%Y%m%d') + trailing_number)
      generate_invoice_number(instance, count.to_i + 1)
    else
      instance.invoice_date.strftime('%Y%m%d') + trailing_number
    end
  end
end
