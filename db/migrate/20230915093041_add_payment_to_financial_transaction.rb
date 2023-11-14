class AddPaymentToFinancialTransaction < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :financial_transactions, :amount, :decimal, precision: 8, scale: 2, default: nil, null: true
      end
      dir.down do
        change_column :financial_transactions, :amount, :decimal, precision: 8, scale: 2, default: 0, null: false
      end
    end

    add_column :financial_transactions, :updated_on, :timestamp
    add_column :financial_transactions, :payment_method, :string
    add_column :financial_transactions, :payment_plugin, :string
    add_column :financial_transactions, :payment_id, :string
    add_column :financial_transactions, :payment_amount, :decimal, precision: 8, scale: 3
    add_column :financial_transactions, :payment_currency, :string
    add_column :financial_transactions, :payment_state, :string
    add_column :financial_transactions, :payment_fee, :decimal, precision: 8, scale: 3

    add_index :financial_transactions, %i[payment_plugin payment_id]
  end
end
