class AddAttachmentToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :attachment_mime, :string
    add_column :users, :attachment_data, :binary, :limit => 8.megabyte
  end
end
