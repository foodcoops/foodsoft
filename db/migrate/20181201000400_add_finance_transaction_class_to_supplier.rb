class AddFinanceTransactionClassToSupplier < ActiveRecord::Migration
  def change
    add_reference :suppliers, :financial_transaction_class
  end
end
