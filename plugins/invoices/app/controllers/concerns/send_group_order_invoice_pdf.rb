module SendGroupOrderInvoicePdf
  extend ActiveSupport::Concern

  protected

  def create_invoice_pdf(group_order_invoice)
    invoice_data = group_order_invoice.load_data_for_invoice
    invoice_data[:title] = t('documents.group_order_invoice_pdf.title', supplier: invoice_data[:supplier])
    invoice_data[:no_footer] = true
    GroupOrderInvoicePdf.new invoice_data
  end

  def send_group_order_invoice_pdf(group_order_invoice)
    pdf = create_invoice_pdf(group_order_invoice)
    send_data pdf.to_pdf, filename: pdf.filename, type: 'application/pdf'
  end
end
