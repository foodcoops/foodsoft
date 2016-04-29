class AddPickupToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :pickup, :date
  end
end
