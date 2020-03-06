class Invoice < ApplicationRecord
  include Attachment
  include CustomFields

  belongs_to :supplier
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'
  belongs_to :financial_link
  has_many :deliveries, dependent: :nullify
  has_many :orders, dependent: :nullify

  validates_presence_of :supplier_id
  validates_numericality_of :amount, :deposit, :deposit_credit

  scope :unpaid, -> { where(paid_on: nil) }
  scope :without_financial_link, -> { where(financial_link: nil) }

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  def user_can_edit?(user)
    user.role_finance? || (user.role_invoices? && !self.paid_on && self.created_by.try(:id) == user.id)
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end
end
