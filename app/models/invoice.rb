class Invoice < ApplicationRecord
  include CustomFields
  include LocalizeInput

  belongs_to :supplier
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'
  belongs_to :financial_link, optional: true
  has_many :deliveries, dependent: :nullify
  has_many :orders, dependent: :nullify

  validates :supplier_id, presence: true
  validates :amount, :deposit, :deposit_credit, numericality: true
  validate :valid_attachment

  scope :unpaid, -> { where(paid_on: nil) }
  scope :without_financial_link, -> { where(financial_link: nil) }

  attr_accessor :delete_attachment

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  def attachment=(incoming_file)
    self.attachment_data = incoming_file.read
    # allow to soft-fail when FileMagic isn't present and removed from Gemfile (e.g. Heroku)
    self.attachment_mime = defined?(FileMagic) ? FileMagic.new(FileMagic::MAGIC_MIME).buffer(attachment_data) : 'application/octet-stream'
  end

  def delete_attachment=(value)
    return unless value == '1'

    self.attachment_data = nil
    self.attachment_mime = nil
  end

  def user_can_edit?(user)
    user.role_finance? || (user.role_invoices? && !paid_on && created_by.try(:id) == user.id)
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end

  def orders_sum
    orders
      .joins(order_articles: [:article_price])
      .sum('COALESCE(order_articles.units_received, order_articles.units_billed, order_articles.units_to_order)' \
        + '* article_prices.unit_quantity' \
        + '* ROUND((article_prices.price + article_prices.deposit) * (100 + article_prices.tax) / 100, 2)')
  end

  def orders_transport_sum
    orders.sum(:transport)
  end

  def expected_amount
    return net_amount unless orders.any?

    orders_sum + orders_transport_sum
  end

  protected

  def valid_attachment
    return unless attachment_data

    mime = MIME::Type.simplified(attachment_mime)
    return if ['application/pdf', 'image/jpeg'].include? mime

    errors.add :attachment, I18n.t('model.invoice.invalid_mime', mime: mime)
  end
end
