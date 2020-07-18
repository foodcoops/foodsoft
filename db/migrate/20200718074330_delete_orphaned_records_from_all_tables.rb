class DeleteOrphanedRecordsFromAllTables < ActiveRecord::Migration
  def up
    execute "DELETE FROM articles WHERE article_category_id NOT IN (SELECT id FROM article_categories)"
    execute "DELETE FROM article_prices WHERE article_id NOT IN (SELECT id FROM articles)"
    execute "DELETE FROM group_orders WHERE updated_by_user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM financial_transactions WHERE user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM group_order_articles WHERE order_article_id NOT IN (SELECT id FROM articles)"
    execute "DELETE FROM invites WHERE user_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM messages WHERE sender_id NOT IN (SELECT id FROM users)"
    execute "DELETE FROM messages WHERE group_id NOT IN (SELECT id FROM groups)"
    execute "DELETE FROM message_recipients WHERE user_id NOT IN (SELECT id FROM users) OR message_id NOT IN (SELECT id FROM messages)"
    execute "DELETE FROM group_order_article_quantities WHERE group_order_article_id NOT IN (SELECT id FROM articles)"
    execute "DELETE FROM group_order_articles WHERE group_order_id NOT IN (SELECT id FROM group_orders)"
    execute "DELETE FROM group_orders WHERE ordergroup_id NOT IN (SELECT id FROM groups)"
    execute "DELETE FROM group_order_articles WHERE group_order_id NOT IN (SELECT id FROM group_orders)"
    execute "DELETE FROM order_articles WHERE article_id NOT IN (SELECT id FROM articles)"
    execute "DELETE FROM order_comments WHERE order_id NOT IN (SELECT id FROM orders) OR user_id NOT IN (SELECT id FROM users)"
    execute "UPDATE orders SET supplier_id=NULL WHERE supplier_id NOT IN (SELECT id FROM suppliers)"
    execute "UPDATE orders SET updated_by_user_id=NULL WHERE updated_by_user_id NOT IN (SELECT id FROM users)"
    execute "UPDATE orders SET created_by_user_id=NULL WHERE created_by_user_id NOT IN (SELECT id FROM users)"

    # We're not going to be able to add a FK constraint for settings, but still...:
    execute "DELETE FROM settings WHERE thing_type = 'User' AND thing_id NOT IN (SELECT id FROM users)"
  end
end