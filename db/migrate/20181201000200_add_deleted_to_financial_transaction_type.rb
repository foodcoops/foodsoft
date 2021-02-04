class AddDeletedToFinancialTransactionType < ActiveRecord::Migration[4.2]
  def change
    change_table :financial_transactions do |t|
      t.integer :reverts_id
      t.index :reverts_id, unique: true
    end
  end
end
