class CreateGroupOrderInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :group_order_invoices do |t|
      t.integer :group_order_id
      t.bigint :invoice_number, unique: true, limit: 8
      t.date :invoice_date
      t.string :payment_method
      t.boolean :paid, default: false, null: false
      t.boolean :sepa_downloaded, default: false, null: false
      t.string :sepa_sequence_type, default: 'RCUR'

      t.timestamps
    end
    add_index :group_order_invoices, :group_order_id, unique: true
  end
end
