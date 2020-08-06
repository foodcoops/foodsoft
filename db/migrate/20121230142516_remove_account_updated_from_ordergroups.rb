class RemoveAccountUpdatedFromOrdergroups < ActiveRecord::Migration[4.2]
  def up
    remove_column :groups, :account_updated
  end

  def down
    add_column :groups, :account_updated, :datetime
  end
end
