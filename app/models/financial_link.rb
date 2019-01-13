class FinancialLink < ApplicationRecord
  has_many :bank_transactions
  has_many :financial_transactions
  has_many :invoices
end
