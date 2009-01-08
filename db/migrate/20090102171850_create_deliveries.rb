class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries do |t|
      t.integer :supplier_id
      t.date :delivered_on
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :deliveries
  end
end
