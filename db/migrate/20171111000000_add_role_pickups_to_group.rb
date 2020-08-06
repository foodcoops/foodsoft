class AddRolePickupsToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :role_pickups, :boolean, default: false, null: false
  end
end
