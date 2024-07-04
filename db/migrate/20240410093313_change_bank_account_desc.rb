class ChangeBankAccountDesc < ActiveRecord::Migration[7.0]
  def up
    change_column :bank_accounts, :description, :text
  end

  def down
    change_column :bank_accounts, :description, :string
  end
end
