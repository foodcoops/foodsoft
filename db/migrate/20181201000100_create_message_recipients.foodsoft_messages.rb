class CreateMessageRecipients < ActiveRecord::Migration
  class Message < ActiveRecord::Base
    has_many :message_recipients
  end

  class MessageRecipient < ActiveRecord::Base
  end

  def up
    create_table :message_recipients do |t|
      t.references :message, index: true, null: false
      t.references :user, null: false
      t.integer :email_state, default: 0, null: false
      t.datetime :read_at
    end

    add_index :message_recipients, [:user_id, :read_at]

    Message.all.each do |m|
      recipients = YAML.load(m.recipients_ids).map do |r|
        {
          message_id: m.id,
          user_id: r,
          email_state: m.email_state
        }
      end
      MessageRecipient.create! recipients
    end

    change_table :messages do |t|
      t.remove :recipients_ids
      t.remove :email_state
    end
  end

  def down
    change_table :messages do |t|
      t.text :recipients_ids
      t.integer :email_state, default: 0, null: false
    end

    messages = Message.all.includes(:message_recipients).map do |m|
      recipients = m.message_recipients.map(&:user_id)
      m.recipients_ids = recipients.to_yaml
      m.email_state = m.email_state
      m.save!
    end

    drop_table :message_recipients
  end
end
