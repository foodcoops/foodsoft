# app/models/concerns/invoice_common.rb
module InvoiceCommon
  extend ActiveSupport::Concern

  included do
    include InvoiceHelper

    validates_presence_of :invoice_number
    validates_uniqueness_of :invoice_number
    validate :tax_number_set

    after_initialize :init, unless: :persisted?
  end

  def mark_sepa_downloaded
    self.sepa_downloaded = true
    save
  end

  def unmark_sepa_downloaded
    self.sepa_downloaded = false
    save
  end

  def name
    I18n.t("activerecord.attributes.#{self.class.name.underscore}.name") + "_#{invoice_number}"
  end

  def tax_number_set
    return if FoodsoftConfig[:contact][:tax_number].present?

    errors.add(:base, I18n.t('activerecord.attributes.group_order_invoice.tax_number_not_set'))
  end
end
