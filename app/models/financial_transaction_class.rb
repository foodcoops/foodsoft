class FinancialTransactionClass < ActiveRecord::Base
  has_many :financial_transaction_types

  validates :name, presence: true

  scope :table_columns, -> { order(name: :asc) }
end
