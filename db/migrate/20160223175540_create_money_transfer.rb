class CreateMoneyTransfer < ActiveRecord::Migration
  def change
    create_table :money_transfers do |t|
      t.string :description
    end

    add_column :bank_transactions, :money_transfer_id, :integer
    add_column :financial_transactions, :money_transfer_id, :integer
    add_column :invoices, :money_transfer_id, :integer
  end
end
