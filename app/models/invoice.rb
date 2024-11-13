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

  def orders_sum(type = :without_markup)
    if type == :without_markup
      orders.sum { |order| order.sum(:groups_without_markup) }
    elsif type == :with_markup
      orders.sum { |order| order.sum(:groups) } 
    end
  end

  def orders_transport_sum
    orders.sum(:transport)
  end

  def deliveries_sum(type = :without_markup)
    if type == :without_markup
      deliveries.sum(&:sum) 
    elsif type == :with_markup  
      deliveries.sum  { |delivery| delivery.sum(:fc) }
    end
  end

  def expected_amount(type = :without_markup)
    return net_amount unless orders.any?

    orders_sum(type) + orders_transport_sum + deliveries_sum(type)  
  end

  protected

  # validates that the attachments are jpeg, png or pdf
  def valid_attachments
    attachments.each do |attachment|
      errors.add(:attachments, I18n.t('model.invoice.invalid_mime', mime: attachment.content_type)) unless attachment.content_type.in?(%w[image/jpeg image/png application/pdf])
    end
  end
end
