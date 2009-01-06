class AddMinOrderQuantity < ActiveRecord::Migration
  def self.up
    add_column :suppliers, :min_order_quantity, :string
  end

  def self.down
    remove_column :suppliers, :min_order_quantity
  end
end
