class Invoice < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :delivery
  belongs_to :order

  validates_presence_of :supplier_id
  validates_numericality_of :amount, :deposit, :deposit_credit

  scope :unpaid, :conditions => { :paid_on => nil }

  # Replace numeric seperator with database format
  localize_input_of :amount, :deposit, :deposit_credit

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end
end


# == Schema Information
#
# Table name: invoices
#
#  id             :integer(4)      not null, primary key
#  supplier_id    :integer(4)
#  delivery_id    :integer(4)
#  order_id       :integer(4)
#  number         :string(255)
#  date           :date
#  paid_on        :date
#  note           :text
#  amount         :decimal(8, 2)   default(0.0), not null
#  deposit        :decimal(8, 2)   default(0.0), not null
#  deposit_credit :decimal(8, 2)   default(0.0), not null
#  created_at     :datetime
#  updated_at     :datetime
#

