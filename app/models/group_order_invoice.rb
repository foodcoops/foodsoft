class GroupOrderInvoice < ApplicationRecord
  belongs_to :group_order
  validates_presence_of :group_order
  validates_uniqueness_of :invoice_number
  validate :tax_number_set
  after_initialize :init, unless: :persisted?

  def generate_invoice_number(count)
    trailing_number = count.to_s.rjust(4, '0')
    if GroupOrderInvoice.find_by(invoice_number: self.invoice_date.strftime("%Y%m%d") + trailing_number)
      generate_invoice_number(count.to_i + 1)
    else
      self.invoice_date.strftime("%Y%m%d") + trailing_number
    end
  end

  def tax_number_set
    if FoodsoftConfig[:contact][:tax_number].blank?
      errors.add(:group_order_invoice, "Keine Steuernummer in FoodsoftConfig :contact gesetzt")
    end
  end

  def init
    self.invoice_date = Time.now unless invoice_date
    self.invoice_number = generate_invoice_number(1) unless self.invoice_number
    self.payment_method = FoodsoftConfig[:group_order_invoices]&.[](:payment_method) || I18n.t('activerecord.attributes.group_order_invoice.payment_method') unless self.payment_method
  end

  def name
    I18n.t('activerecord.attributes.group_order_invoice.name') + "_#{invoice_number}"
  end

  def load_data_for_invoice
    invoice_data = {}
    order = group_order.order
    invoice_data[:supplier] = order.supplier.name
    invoice_data[:ordergroup] = group_order.ordergroup
    invoice_data[:group_order] = group_order
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
        :price => order_article.article.fc_price,
        :quantity => (goa ? goa.quantity : 0),
        :total_price => (goa ? goa.total_price : 0),
        :tax => order_article.article.tax
      }
    end
    invoice_data
  end
end
