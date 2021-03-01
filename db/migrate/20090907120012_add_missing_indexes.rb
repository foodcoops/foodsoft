class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def self.up
    add_index "article_prices", ["article_id"]

    add_index "articles", ["supplier_id"]
    add_index "articles", ["article_category_id"]
    add_index "articles", ["type"]

    add_index "deliveries", ["supplier_id"]

    add_index "financial_transactions", ["ordergroup_id"]

    add_index "group_order_article_quantities", ["group_order_article_id"]
    add_index "group_orders", ["order_id"]
    add_index "group_orders", ["ordergroup_id"]

    add_index "invoices", ["supplier_id"]
    add_index "invoices", ["delivery_id"]

    add_index "order_articles", ["order_id"]

    add_index "order_comments", ["order_id"]

    add_index "orders", ["state"]

    add_index "stock_changes", ["delivery_id"]
    add_index "stock_changes", ["stock_article_id"]
    add_index "stock_changes", ["stock_taking_id"]

    add_index "tasks", ["workgroup_id"]
  end

  def self.down
  end
end
