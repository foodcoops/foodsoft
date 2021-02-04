class AllowEmtpyOrdergroupInFinancialTransaction < ActiveRecord::Migration[4.2]
  def change
    change_column_null :financial_transactions, :ordergroup_id, true
  end
end
