class ChangeOrdergroupDefaultInFinancialTransaction < ActiveRecord::Migration[4.2]
  class FinancialTransaction < ActiveRecord::Base; end

  def up
    change_column_default :financial_transactions, :ordergroup_id, nil
    FinancialTransaction.where(ordergroup_id: 0).update_all(ordergroup_id: nil)
  end

  def down
    FinancialTransaction.where(ordergroup_id: nil).update_all(ordergroup_id: 0)
    change_column_default :financial_transactions, :ordergroup_id, 0
  end
end
