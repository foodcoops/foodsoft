class AddQuantitiesToOrderArticle < ActiveRecord::Migration
  def change
    add_column :order_articles, :units_billed, :integer
    add_column :order_articles, :units_received, :integer
  end
end
