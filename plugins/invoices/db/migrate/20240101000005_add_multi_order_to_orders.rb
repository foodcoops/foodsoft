class AddMultiOrderToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :multi_order, foreign_key: true
  end
end
