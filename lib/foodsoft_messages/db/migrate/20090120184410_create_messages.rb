# extracted from 20090120184410_road_to_version_three.rb
class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.references :sender
      t.text :recipients_ids
      t.string :subject, :null => false
      t.text :body
      t.integer :email_state, :default => 0, :null => false
      t.boolean :private, :default => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :messages
  end
end
