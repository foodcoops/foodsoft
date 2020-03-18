class AddTransportToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :transport, :decimal, precision: 8, scale: 2
    add_column :group_orders, :transport, :decimal, precision: 8, scale: 2
  end
end
