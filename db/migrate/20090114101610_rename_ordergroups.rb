class RenameOrdergroups < ActiveRecord::Migration
  def self.up
    rename_column :financial_transactions, :order_group_id, :ordergroup_id
    rename_column :group_orders, :order_group_id, :ordergroup_id
    rename_column :tasks, :group_id, :workgroup_id
    remove_index :group_orders, :name => "index_group_orders_on_order_group_id_and_order_id"
    add_index :group_orders, [:ordergroup_id, :order_id], :unique => true

    Group.find(:all, :conditions => { :type => "OrderGroup" }).each do |ordergroup|
      ordergroup.update_attribute(:type, "Ordergroup")
    end
  end

  def self.down
  end
end
