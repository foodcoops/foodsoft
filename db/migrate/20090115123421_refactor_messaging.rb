class RefactorMessaging < ActiveRecord::Migration
  def self.up
    
    drop_table :messages
    
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
  end
end
