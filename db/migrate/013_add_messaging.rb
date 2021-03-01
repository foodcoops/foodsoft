class AddMessaging < ActiveRecord::Migration[4.2]
  def self.up
    # Table that holds the messages:
    create_table :messages do |t|
      t.column :sender_id, :integer
      t.column :recipient_id, :integer, :null => false
      t.column :recipients, :string, :null => false
      t.column :subject, :string, :null => false
      t.column :body, :text, :null => false
      t.column :read, :boolean, :null => false, :default => false
      t.column :email_state, :integer, :null => false
      t.column :created_on, :timestamp, :null => false
    end
    add_index(:messages, :sender_id)
    add_index(:messages, :recipient_id)

    # Setup acts_as_configurable plugin for user options etc.
    ConfigurableSetting.create_table
  end

  def self.down
    drop_table :messages
    ConfigurableSetting.drop_table
  end
end
