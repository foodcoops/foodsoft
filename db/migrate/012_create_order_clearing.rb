class CreateOrderClearing < ActiveRecord::Migration[4.2]
  def self.up
    add_column :orders, :invoice_amount, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
    add_column :orders, :refund, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
    add_column :orders, :refund_credit, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
    add_column :orders, :invoice_number, :string
    add_column :orders, :invoice_date, :string
  end

  def self.down
    remove_column :orders, :invoice_amount
    remove_column :orders, :refund
    remove_column :orders, :refund_credit
    remove_column :orders, :invoice_number
    remove_column :orders, :invoice_date
  end
end
