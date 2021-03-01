class UserPasswordReset < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_expires, :timestamp
  end

  def self.down
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_expires
  end
end
