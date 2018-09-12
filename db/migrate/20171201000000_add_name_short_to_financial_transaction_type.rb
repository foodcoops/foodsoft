class AddNameShortToFinancialTransactionType < ActiveRecord::Migration
  def change
    add_column :financial_transaction_types, :name_short, :string
    add_index :financial_transaction_types, :name_short
  end
end
