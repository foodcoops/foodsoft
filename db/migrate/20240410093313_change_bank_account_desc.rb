class ChangeBankAccountDesc < ActiveRecord::Migration[7.0]
  def change
    change_column :bank_accounts, :description, :text, 
  end
end
