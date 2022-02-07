class AddIgnoreForAccountBalanceToFinancialTransactionClasses < ActiveRecord::Migration[4.2]
  def change
    add_column :financial_transaction_classes, :ignore_for_account_balance, :boolean, default: false, null: false
  end
end
