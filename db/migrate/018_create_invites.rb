class CreateInvites < ActiveRecord::Migration[4.2]
  def self.up
    create_table :invites do |t|
      t.column :token, :string, :null => false
      t.column :expires_at, :timestamp, :null => false
      t.column :group_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :email, :string, :null => false
    end
    add_index :invites, :token
  end

  def self.down
    drop_table :invites
  end
end
