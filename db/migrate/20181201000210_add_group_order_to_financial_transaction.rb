class AddGroupOrderToFinancialTransaction < ActiveRecord::Migration
  def change
    add_reference :financial_transactions, :group_order
  end
end
