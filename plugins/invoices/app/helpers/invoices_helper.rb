module InvoicesHelper
  def generate_invoice_number(instance, count)
    trailing_number = count.to_s.rjust(4, '0')
    if GroupOrderInvoice.find_by(invoice_number: instance.invoice_date.strftime('%Y%m%d') + trailing_number)
      generate_invoice_number(instance, count.to_i + 1)
    else
      instance.invoice_date.strftime('%Y%m%d') + trailing_number
    end
  end
end
