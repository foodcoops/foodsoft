class CreateMultiOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :multi_orders do |t|
      t.datetime :ends

      t.timestamps
    end
  end
end
