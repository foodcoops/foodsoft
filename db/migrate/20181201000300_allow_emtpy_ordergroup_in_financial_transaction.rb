class AllowEmtpyOrdergroupInFinancialTransaction < ActiveRecord::Migration
  def change
    change_column_null :financial_transactions, :ordergroup_id, true
  end
end
