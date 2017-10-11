class AddEndActionToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :end_action, :integer, default: 0, null: false
  end
end
