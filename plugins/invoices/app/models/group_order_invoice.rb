class GroupOrderInvoice < ApplicationRecord
  include InvoiceCommon

  belongs_to :group_order
  validates_presence_of :group_order
  validates_uniqueness_of :group_order_id

  def init
    self.invoice_date = Time.now unless invoice_date
    self.invoice_number = generate_invoice_number(self, 1) unless invoice_number
    transaction_type = group_order&.financial_transaction&.financial_transaction_type
    self.payment_method = transaction_type&.name || FoodsoftConfig[:group_order_invoices]&.[](:payment_method) || I18n.t('activerecord.attributes.group_order_invoice.payment_method') unless payment_method
  end

  def load_data_for_invoice
    invoice_data = {}
    order = group_order.order
    invoice_data[:pickup] = order.pickup
    invoice_data[:supplier] = order.supplier&.name
    invoice_data[:ordergroup] = group_order.ordergroup
    invoice_data[:group_order_ids] = [group_order.id]
    invoice_data[:invoice_number] = invoice_number
    invoice_data[:invoice_date] = invoice_date
    invoice_data[:tax_number] = FoodsoftConfig[:contact][:tax_number]
    invoice_data[:payment_method] = payment_method
    invoice_data[:order_articles] = {}
    group_order.order_articles.each do |order_article|
      # Get the result of last time ordering, if possible
      goa = group_order.group_order_articles.detect { |tmp_goa| tmp_goa.order_article_id == order_article.id }

      # Build hash with relevant data
      invoice_data[:order_articles][order_article.id] = {
        price: order_article.article_version.fc_price,
        quantity: (goa ? goa.quantity : 0),
        total_price: (goa ? goa.total_price : 0),
        tax: order_article.article_version.tax
      }
    end
    invoice_data
  end
end
