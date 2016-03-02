class AllowStockGroupOrder < ActiveRecord::Migration
  def self.up
    change_column :group_orders, :ordergroup_id, :integer, :default => nil, :null => true
  end

  def self.down
    change_column :group_orders, :ordergroup_id, :integer, :default => 0, :null => false
  end
end
