class AddEmailToMessage < ActiveRecord::Migration[4.2]
  def change
    add_column :messages, :salt, :string
    add_column :messages, :received_email, :binary, :limit => 1.megabyte
  end
end
