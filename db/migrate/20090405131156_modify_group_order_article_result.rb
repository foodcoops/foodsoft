class ModifyGroupOrderArticleResult < ActiveRecord::Migration[4.2]
  def self.up
    change_column :group_order_articles, :result, :decimal, :precision => 8, :scale => 3
  end

  def self.down
    change_column :group_order_articles, :result, :integer
  end
end
