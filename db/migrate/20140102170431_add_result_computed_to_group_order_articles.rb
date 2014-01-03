class AddResultComputedToGroupOrderArticles < ActiveRecord::Migration
  def change
    add_column :group_order_articles, :result_computed,
      :decimal, :precision => 8, :scale => 3,
      :null => false, :default => 0
  end
end
