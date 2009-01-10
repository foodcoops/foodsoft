# == Schema Information
# Schema version: 20090102171850
#
# Table name: financial_transactions
#
#  id             :integer(4)      not null, primary key
#  order_group_id :integer(4)      default(0), not null
#  amount         :decimal(8, 2)   default(0.0), not null
#  note           :text            default(""), not null
#  user_id        :integer(4)      default(0), not null
#  created_on     :datetime        not null
#

# financial transactions are the foodcoop internal financial transactions
# only order_groups have an account  balance and are happy to transfer money
class FinancialTransaction < ActiveRecord::Base
  belongs_to :order_group
  belongs_to :user
  
  validates_presence_of :note, :user_id, :order_group_id
  validates_numericality_of :amount

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def amount=(amount)
    self[:amount] = String.delocalized_decimal(amount)
  end

end
