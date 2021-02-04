class ChangeDeliveredOnToDate < ActiveRecord::Migration[4.2]
  def change
    rename_column :deliveries, :delivered_on, :date
  end
end
