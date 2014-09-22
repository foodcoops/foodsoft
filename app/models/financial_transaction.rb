# financial transactions are the foodcoop internal financial transactions
# only ordergroups have an account  balance and are happy to transfer money
class FinancialTransaction < ActiveRecord::Base
  belongs_to :ordergroup
  belongs_to :user

  validates_presence_of :amount, :note, :user_id, :ordergroup_id
  validates_numericality_of :amount, greater_then: -100_000,
    less_than: 100_000

  localize_input_of :amount

  # Use this save method instead of simple save and after callback
  def add_transaction!
    ordergroup.add_financial_transaction! amount, note, user
  end
end
