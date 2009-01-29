# == Schema Information
# Schema version: 20090120184410
#
# Table name: invoices
#
#  id             :integer(4)      not null, primary key
#  supplier_id    :integer(4)
#  delivery_id    :integer(4)
#  number         :string(255)
#  date           :date
#  paid_on        :date
#  note           :text
#  amount         :decimal(8, 2)   default(0.0), not null
#  created_at     :datetime
#  updated_at     :datetime
#  order_id       :integer(4)
#  deposit        :decimal(8, 2)   default(0.0), not null
#  deposit_credit :decimal(8, 2)   default(0.0), not null
#

class Invoice < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :delivery
  belongs_to :order

  validates_presence_of :supplier_id
  validates_uniqueness_of :date, :scope => [:supplier_id]

  named_scope :unpaid, :conditions => { :paid_on => nil }

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def amount=(amount)
    self[:amount] = String.delocalized_decimal(amount)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit=(deposit)
    self[:deposit] = String.delocalized_decimal(deposit)
  end

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit_credit=(deposit)
    self[:deposit_credit] = String.delocalized_decimal(deposit)
  end

  # Amount without deposit
  def net_amount
    amount - deposit + deposit_credit
  end
end
