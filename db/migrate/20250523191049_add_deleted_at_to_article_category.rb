class AddDeletedAtToArticleCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :article_categories, :deleted_at, :datetime
    add_index :article_categories, :deleted_at
  end

  def up
    first_article_category = select('SELECT id FROM article_categories LIMIT 1')

    update(%(
      UPDATE article_versions
      SET article_category_id = #{quote first_article_category['id']}
      WHERE article_category_id NOT IN (SELECT id FROM article_categories)
    )) unless first_article_category.nil?
  end
end
