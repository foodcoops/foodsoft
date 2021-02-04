class ChangeResultQuantities < ActiveRecord::Migration[4.2]
  def self.up
    change_column :group_order_article_results, :quantity, :decimal, :precision => 6, :scale => 3
    change_column :order_article_results, :units_to_order, :decimal, :precision => 6, :scale => 3, :null => false
  end

  def self.down
    change_column :group_order_article_results, :quantity, :integer, :null => false
    change_column :order_article_results, :units_to_order,:integer, :default => 0, :null => false
  end
end
