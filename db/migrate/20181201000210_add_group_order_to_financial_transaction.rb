class AddGroupOrderToFinancialTransaction < ActiveRecord::Migration[4.2]
  def change
    add_reference :financial_transactions, :group_order
  end
end
