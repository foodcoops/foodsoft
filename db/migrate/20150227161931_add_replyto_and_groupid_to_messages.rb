class AddReplytoAndGroupidToMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :messages, :reply_to, :integer
    add_column :messages, :group_id, :integer
  end
end
