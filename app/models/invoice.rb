class Invoice < ApplicationRecord
  include CustomFields
  include LocalizeInput

  belongs_to :supplier
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'
  belongs_to :financial_link, optional: true
  has_many :deliveries, dependent: :nullify
  has_many :orders, dependent: :nullify
  has_many_attached :attachments

  validates :supplier_id, presence: true
  validates :amount, :deposit, :deposit_credit, numericality: true
  validate :valid_attachments

  scope :unpaid, -> { where(paid_on: nil) }
  scope :without_financial_link, -> { where(financial_link: nil) }

  attr_accessor :delete_attachment

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit


  def user_can_edit?(user)
    user.role_finance? || (user.role_invoices? && !paid_on && created_by.try(:id) == user.id)
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end

  def orders_sum
    orders
      .joins(order_articles: [:article_version])
      .sum('COALESCE(order_articles.units_received, order_articles.units_billed, order_articles.units_to_order)' \
        + '* ROUND((article_versions.price + article_versions.deposit) * (100 + article_versions.tax) / 100, 2)')
  end

  def orders_transport_sum
    orders.sum(:transport)
  end

  def expected_amount
    return net_amount unless orders.any?

    orders_sum + orders_transport_sum
  end

  protected

  # validates that the attachments are jpeg, png or pdf
  def valid_attachments
    attachments.each do |attachment|
      errors.add(:attachments, I18n.t('model.invoice.invalid_mime', mime: attachment.content_type)) unless attachment.content_type.in?(%w[image/jpeg image/png application/pdf])
    end
  end
end
