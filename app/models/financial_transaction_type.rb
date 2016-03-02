class FinancialTransactionType < ActiveRecord::Base
  belongs_to :financial_transaction_class
  has_many :financial_transactions

  validates :name, presence: true
  validates :financial_transaction_class, presence: true
end
