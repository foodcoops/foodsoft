class RenameOrderTimestampAndAddRemoteOrderFieldsToSupplier < ActiveRecord::Migration[7.0]
  def change
    change_table :orders do |t|
      t.rename :last_sent_mail, :remote_ordered_at
    end
    change_table :suppliers do |t|
      t.column :remote_order_method, :string, null: false, default: 'email'
      t.column :remote_order_url, :string
    end
  end
end
