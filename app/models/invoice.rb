# == Schema Information
# Schema version: 20090113111624
#
# Table name: invoices
#
#  id          :integer(4)      not null, primary key
#  supplier_id :integer(4)
#  delivery_id :integer(4)
#  number      :string(255)
#  date        :date
#  paid_on     :date
#  note        :text
#  amount      :decimal(8, 2)   default(0.0), not null
#  created_at  :datetime
#  updated_at  :datetime
#

class Invoice < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :delivery

  validates_presence_of :supplier_id
  validates_uniqueness_of :date, :scope => [:supplier_id]

  named_scope :unpaid, :conditions => { :paid_on => nil }

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def amount=(amount)
    self[:amount] = String.delocalized_decimal(amount)
  end
end
