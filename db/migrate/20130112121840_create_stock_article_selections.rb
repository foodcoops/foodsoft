class CreateStockArticleSelections < ActiveRecord::Migration
  def up
    create_table :stock_article_selections do |t|
      t.integer :created_by_user_id
      t.timestamps
    end
    
    create_table :stock_article_selections_stock_articles, :id => false do |t|
      t.integer :stock_article_id
      t.integer :stock_article_selection_id
    end
  end

  def down
    drop_table :stock_article_selections
    drop_table :stock_article_selections_stock_articles
  end
end
