class ChangeOrderArticleResultTypes < ActiveRecord::Migration[4.2]
  def self.up
    change_column :order_articles, :units_billed, :decimal, precision: 8, scale: 3
    change_column :order_articles, :units_received, :decimal, precision: 8, scale: 3
  end

  def self.down
    change_column :order_articles, :units_billed, :integer
    change_column :order_articles, :units_received, :integer
  end
end
