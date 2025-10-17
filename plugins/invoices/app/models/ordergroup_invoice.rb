class OrdergroupInvoice < ApplicationRecord
  include InvoiceCommon

  belongs_to :multi_group_order

  after_initialize :init, unless: :persisted?

  def init
    self.invoice_date = Time.now unless invoice_date
    self.invoice_number = generate_invoice_number(self, 1) unless invoice_number
    transaction_type = multi_group_order&.financial_transaction&.financial_transaction_type
    self.payment_method = transaction_type&.name || FoodsoftConfig[:ordergroup_invoices]&.[](:payment_method) || I18n.t('activerecord.attributes.ordergroup_invoice.payment_method') unless payment_method
  end

  def ordergroup
    return if group_orders.empty?

    group_orders.first.ordergroup
  end

  def send_invoice
    NotifyOrdergroupInvoiceJob.perform_later(self)
  end

  def load_data_for_invoice
    invoice_data = {}
    group_orders = multi_group_order.group_orders
    order = group_orders.map(&:order).first
    # how to define one order?

    invoice_data[:pickup] = order.pickup
    invoice_data[:supplier] = FoodsoftConfig[:name]
    invoice_data[:ordergroup] = group_orders.first.ordergroup
    invoice_data[:group_order_ids] = group_orders.pluck(:id)
    invoice_data[:invoice_number] = invoice_number
    invoice_data[:invoice_date] = invoice_date
    invoice_data[:tax_number] = FoodsoftConfig[:contact][:tax_number]
    invoice_data[:payment_method] = payment_method
    invoice_data[:order_articles] = {}
    group_orders.map(&:order_articles).flatten.each do |order_article|
      # Get the result of last time ordering, if possible
      # goa = group_orders.group_order_articles.detect { |tmp_goa| tmp_goa.order_article_id == order_article.id }
      goa = group_orders.map(&:group_order_articles).flatten.detect { |tmp_goa| tmp_goa.order_article_id == order_article.id }
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
