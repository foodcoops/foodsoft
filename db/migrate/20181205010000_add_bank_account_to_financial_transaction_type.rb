class AddBankAccountToFinancialTransactionType < ActiveRecord::Migration
  def change
    add_reference :financial_transaction_types, :bank_account
  end
end
