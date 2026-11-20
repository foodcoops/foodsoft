class AddMultiGroupOrderToGroupOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :group_orders, :multi_group_order, foreign_key: true
  end
end
