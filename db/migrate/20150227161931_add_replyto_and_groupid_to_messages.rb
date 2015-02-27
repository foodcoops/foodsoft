class AddReplytoAndGroupidToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :reply_to, :integer
    add_column :messages, :group_id, :integer
  end
end
