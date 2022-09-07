module Concerns::SendGroupOrderInvoicePdf
  extend ActiveSupport::Concern

  protected

  def send_group_order_invoice_pdf(group_order_invoice)
    invoice_data = group_order_invoice.load_data_for_invoice
    invoice_data[:title] = t('documents.group_order_invoice_pdf.title', supplier: invoice_data[:supplier])
    invoice_data[:no_footer] = true
    pdf = GroupOrderInvoicePdf.new invoice_data
    send_data pdf.to_pdf, filename: pdf.filename, type: 'application/pdf'
  end
end
