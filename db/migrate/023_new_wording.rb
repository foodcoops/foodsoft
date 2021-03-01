class NewWording < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :articles, :clear_price, :net_price
    rename_column :articles, :refund, :deposit

    rename_column :order_article_results, :clear_price, :net_price
    rename_column :order_article_results, :refund, :deposit

    rename_column :orders, :refund, :deposit
    rename_column :orders, :refund_credit, :deposit_credit
  end

  def self.down
    rename_column :articles, :net_price, :clear_price
    rename_column :articles, :deposit, :refund

    rename_column :order_article_results, :net_price, :clear_price
    rename_column :order_article_results, :deposit, :refund

    rename_column :orders, :deposit, :refund
    rename_column :orders, :deposit_credit, :refund_credit
  end
end
