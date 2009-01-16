class CreateStockChanges < ActiveRecord::Migration
  def self.up
    create_table :stock_changes do |t|
      t.references :delivery
      t.references :order
      t.references :article
      t.decimal :quantity, :precision => 6, :scale => 2, :default => 0.0
      t.datetime :created_at
    end

    add_column :articles, :quantity, :decimal, :precision => 6, :scale => 2, :default => 0.0
  end

  def self.down
    drop_table :stock_changes
  end
end
