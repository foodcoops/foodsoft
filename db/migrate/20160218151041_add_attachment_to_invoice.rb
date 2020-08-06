class AddAttachmentToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :attachment_mime, :string
    add_column :invoices, :attachment_data, :binary, :limit => 8.megabyte
  end
end
