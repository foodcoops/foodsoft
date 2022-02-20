class CreateArticlePrices < ActiveRecord::Migration[4.2]
  def self.up
    create_table :article_prices do |t|
      t.column :article_id, :int, :null => false
      t.column :clear_price, :decimal, :precision => 8, :scale => 2, :null => false
      t.column :gross_price, :decimal, :precision => 8, :scale => 2, :null => false # gross price, incl. vat, refund and price markup
      t.column :tax, :float, :null => false, :default => 0
      t.column :refund, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
      t.column :updated_on, :datetime
      t.column :unit_quantity, :int, :default => 1, :null => false
      t.column :order_number, :string
    end
    add_index(:article_prices, :article_id)

    # add some prices ...
    puts 'add prices to the sample articles'
    CreateArticles::SAMPLE_ARTICLE_NAMES.each do |a|
      puts 'Create Price for article ' + a
      raise "article #{a} not found!" unless article = Article.find_by_name(a)

      new_price = ArticlePrice.new(:clear_price => rand(4) + 1,
                                   :tax => 7.0,
                                   :refund => 0,
                                   :unit_quantity => rand(10) + 1,
                                   :order_number => rand(9999))
      article.add_price(new_price)
      raise 'Failed!' unless ArticlePrice.find_by_article_id(article.id)
    end
    raise 'Failed!' unless ArticlePrice.find(:all).length == CreateArticles::SAMPLE_ARTICLE_NAMES.length
  end

  def self.down
    drop_table :article_prices
  end
end
