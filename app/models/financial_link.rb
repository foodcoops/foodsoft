class FinancialLink < ActiveRecord::Base
  has_many :financial_transactions
  has_many :invoices
end
