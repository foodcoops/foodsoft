class AddAbbreviationToFinancialTransactionType < ActiveRecord::Migration
  def change
    add_column :financial_transaction_types, :abbreviation, :string
    add_index :financial_transaction_types, :abbreviation, unique: true
  end
end
