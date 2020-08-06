class AddMinOrderQuantity < ActiveRecord::Migration[4.2]
  def self.up
    add_column :suppliers, :min_order_quantity, :string
  end

  def self.down
    remove_column :suppliers, :min_order_quantity
  end
end
