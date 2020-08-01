class ChangeDeliveredOnToDate < ActiveRecord::Migration
  def change
    rename_column :deliveries, :delivered_on, :date
  end
end
