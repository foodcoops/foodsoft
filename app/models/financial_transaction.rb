# financial transactions are the foodcoop internal financial transactions
# only order_groups have an account  balance and are happy to transfer money
# 
# financial transaction have the following attributes:
# * order_group_id      (int)
# * amount	           (decimal)
# * note            (text)
# * created_on      (datetime)
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
