namespace :db do
  desc "Add performance indexes for messages visibility"
  task add_message_indexes: :environment do
    Rails.logger.info("task db:add_message_indexes started")
    # Messages visibility index
    ActiveRecord::Migration.add_index :messages,
      [:reply_to, :group_id, :created_at],
      name: "idx_messages_reply_group_created",
      if_not_exists: true

    # Sender visibility index
    ActiveRecord::Migration.add_index :messages,
      [:sender_id, :reply_to, :group_id, :created_at],
      name: "idx_messages_sender_visibility",
      if_not_exists: true

    # Recipient lookup index
    ActiveRecord::Migration.add_index :message_recipients,
      [:user_id, :message_id],
      name: "idx_message_recipients_user_message",
      if_not_exists: true

    puts "Indexes ensured."
    Rails.logger.info("task db:add_message_indexes ended")
  end
end

