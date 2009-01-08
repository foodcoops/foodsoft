class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :supplier_id
      t.integer :delivery_id
      t.string :number
      t.date :date
      t.date :paid_on
      t.text :note
      t.decimal :amount, :null => false, :precision => 8, :scale => 2, :default => 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
