class RemoveTableArticlePrices < ActiveRecord::Migration[4.2]
  def self.up
    puts "create columns in articles ..."
    add_column "articles", "clear_price", :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => false
    add_column "articles", "gross_price", :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => false
    add_column "articles", "tax", :float
    add_column "articles", "refund", :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => false
    add_column "articles", "unit_quantity", :integer, :default => 1,   :null => false
    add_column "articles", "order_number", :string
    add_column "articles", "created_at", :datetime
    add_column "articles", "updated_at", :datetime

    # stop auto-updating the timestamps to make the data-copy safe!
    Article.record_timestamps = false

    puts "now copy values of article_prices into new articles-columns..."
    Article.find(:all).each do |article|
      price = article.current_price
      article.update!(clear_price: price.clear_price,
                      gross_price: price.gross_price,
                      tax: price.tax,
                      refund: price.refund,
                      unit_quantity: price.unit_quantity,
                      order_number: price.order_number,
                      updated_at: price.updated_on,
                      created_at: price.updated_on)
    end

    puts "delete article_prices, current_price attribute"
    drop_table :article_prices
    remove_column :articles, :current_price_id
  end

  def self.down
    add_column :articles, :current_price_id, :integer
    create_table "article_prices", :force => true do |t|
      t.integer  "article_id",                                  :default => 0,   :null => false
      t.decimal  "clear_price",   :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal  "gross_price",   :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.float    "tax",                                         :default => 0.0, :null => false
      t.decimal  "refund", :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.datetime "updated_on"
      t.integer  "unit_quantity", :default => 1, :null => false
      t.string   "order_number"
    end

    # copy data from article now into old ArticlePrice-object
    Article.find(:all).each do |article|
      price = ArticlePrice.create(:clear_price => article.clear_price,
                                  :gross_price => article.gross_price,
                                  :tax => article.tax,
                                  :refund => article.refund,
                                  :unit_quantity => article.unit_quantity,
                                  :order_number => article.order_number.blank? ? nil : article.order_number,
                                  :updated_on => article.updated_at)

      article.update_attribute(:current_price, price)
      price.update_attribute(:article, article)
    end

    # remove new columns
    remove_column "articles", "clear_price"
    remove_column "articles", "gross_price"
    remove_column "articles", "tax"
    remove_column "articles", "refund"
    remove_column "articles", "unit_quantity"
    remove_column "articles", "order_number"
    remove_column "articles", "created_at"
    remove_column "articles", "updated_at"
  end
end
