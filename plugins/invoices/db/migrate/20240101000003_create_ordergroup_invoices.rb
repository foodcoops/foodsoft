class CreateOrdergroupInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :ordergroup_invoices do |t|
      t.date :invoice_date
      t.string :invoice_number
      t.string :payment_method
      t.boolean :paid, default: false, null: false
      t.boolean :sepa_downloaded, default: false, null: false
      t.string :sepa_sequence_type, default: 'RCUR'
      t.references :multi_group_order, foreign_key: true
      t.datetime :email_sent_at
      t.timestamps
    end
  end
end
