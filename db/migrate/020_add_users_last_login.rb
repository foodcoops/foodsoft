class AddUsersLastLogin < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :last_login, :datetime
  end

  def self.down
    remove_column :users, :last_login
  end
end
