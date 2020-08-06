class AddNameShortToFinancialTransactionType < ActiveRecord::Migration[4.2]
  def change
    add_column :financial_transaction_types, :name_short, :string
    add_index :financial_transaction_types, :name_short
  end
end
