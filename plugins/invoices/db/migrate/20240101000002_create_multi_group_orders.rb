class CreateMultiGroupOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :multi_group_orders do |t|
      t.references :multi_order, null: false, foreign_key: true
      t.timestamps
    end
  end
end
