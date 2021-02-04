class AddOrderIndexes < ActiveRecord::Migration[4.2]
  def self.up
    add_index :group_order_articles, :group_order_id
    add_index :group_order_articles, :order_article_id
  end

  def self.down
    remove_index :group_order_articles, :group_order_id
    remove_index :group_order_articles, :order_article_id
  end
end
