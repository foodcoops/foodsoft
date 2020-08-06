class AddBankAccountToFinancialTransactionType < ActiveRecord::Migration[4.2]
  def change
    add_reference :financial_transaction_types, :bank_account
  end
end
