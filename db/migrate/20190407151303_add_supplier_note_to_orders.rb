class AddSupplierNoteToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :supplier_note, :text
  end
end
