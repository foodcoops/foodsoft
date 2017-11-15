class AddRolePickupsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :role_pickups, :boolean, default: false, null: false
  end
end
