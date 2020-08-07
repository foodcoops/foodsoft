class ChangeInvoiceRelation < ActiveRecord::Migration[4.2]
  def up
    add_column :deliveries, :invoice_id, :integer
    execute 'UPDATE deliveries SET invoice_id = (SELECT id FROM invoices WHERE delivery_id = deliveries.id)'
    remove_column :invoices, :delivery_id

    add_column :orders, :invoice_id, :integer
    execute 'UPDATE orders SET invoice_id = (SELECT id FROM invoices WHERE order_id = orders.id)'
    remove_column :invoices, :order_id
  end

  def down
    add_column :invoices, :delivery_id
    execute 'UPDATE invoices SET delivery_id = (SELECT id FROM deliveries WHERE invoice_id = invoices.id)'
    remove_column :deliveries, :invoice_id, :integer

    add_column :invoices, :order_id
    execute 'UPDATE invoices SET order_id = (SELECT id FROM orders WHERE invoice_id = invoices.id)'
    remove_column :orders, :invoice_id, :integer
  end
end
