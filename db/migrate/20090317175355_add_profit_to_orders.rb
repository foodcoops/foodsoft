class AddProfitToOrders < ActiveRecord::Migration[4.2]
  def self.up
    add_column :orders, :foodcoop_result, :decimal, :precision => 8, :scale => 2
    
    Order.closed.each do |order|
      order.update_attribute(:foodcoop_result, order.profit)
    end
  end

  def self.down
    remove_column :orders, :foodcoop_result
  end
end
