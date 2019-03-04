class ChangeFinancialTransactionTypeDefault < ActiveRecord::Migration
  def change
    change_column_default :financial_transactions, :financial_transaction_type_id, 1
  end
end
