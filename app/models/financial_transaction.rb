# financial transactions are the foodcoop internal financial transactions
# only ordergroups have an account  balance and are happy to transfer money
class FinancialTransaction < ActiveRecord::Base
  belongs_to :ordergroup
  belongs_to :user
  belongs_to :financial_link
  belongs_to :financial_transaction_type

  validates_presence_of :amount, :note, :user_id, :ordergroup_id
  validates_numericality_of :amount, greater_then: -100_000,
    less_than: 100_000

  scope :without_financial_link, -> { where(financial_link: nil) }

  localize_input_of :amount

  after_initialize do
    initialize_financial_transaction_type
  end

  # Use this save method instead of simple save and after callback
  def add_transaction!
    ordergroup.add_financial_transaction! amount, note, user, financial_transaction_type
  end

  protected

  def initialize_financial_transaction_type
    self.financial_transaction_type ||= FinancialTransactionType.default
  end
end
