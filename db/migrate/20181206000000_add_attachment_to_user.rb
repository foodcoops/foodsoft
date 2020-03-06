class AddAttachmentToUser < ActiveRecord::Migration
  def change
    add_column :users, :attachment_mime, :string
    add_column :users, :attachment_data, :binary, :limit => 8.megabyte
  end
end
