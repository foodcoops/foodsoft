class Invoice < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'
  has_many :deliveries
  has_many :orders

  validates_presence_of :supplier_id
  validates_numericality_of :amount, :deposit, :deposit_credit

  scope :unpaid, -> { where(paid_on: nil) }

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end
end
