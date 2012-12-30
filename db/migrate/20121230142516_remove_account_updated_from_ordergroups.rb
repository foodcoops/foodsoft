class RemoveAccountUpdatedFromOrdergroups < ActiveRecord::Migration
  def up
    remove_column :groups, :account_updated
  end

  def down
    add_column :groups, :account_updated, :datetime
  end
end
