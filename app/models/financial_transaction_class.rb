class FinancialTransactionClass < ActiveRecord::Base
  has_many :financial_transaction_types, dependent: :destroy

  validates :name, presence: true
  validates_uniqueness_of :name
end
