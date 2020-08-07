class CreateMailDeliveryStatus < ActiveRecord::Migration[4.2]
  def change
    create_table :mail_delivery_status do |t|
      t.datetime :created_at
      t.string :email, :null => false
      t.string :message, :null => false
      t.string :attachment_mime
      t.binary :attachment_data, limit: 16.megabyte

      t.index :email
    end
  end
end
