class EnsureArticleForArticlePrice < ActiveRecord::Migration[4.2]
  class ArticlePrice < ActiveRecord::Base; end

  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE article_prices SET article_id = (
            SELECT article_id FROM order_articles
            WHERE article_price_id = article_prices.id
          )
          WHERE article_id IS NULL
        SQL
        ArticlePrice.where(article_id: nil).destroy_all
      end
    end

    change_column_null :article_prices, :article_id, false
  end
end
