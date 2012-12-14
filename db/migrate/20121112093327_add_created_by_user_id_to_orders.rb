class AddCreatedByUserIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :created_by_user_id, :integer
  end

  def self.down
    remove_column :orders, :created_by_user_id
  end
end
