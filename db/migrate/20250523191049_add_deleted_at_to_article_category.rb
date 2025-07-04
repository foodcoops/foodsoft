class AddDeletedAtToArticleCategory < ActiveRecord::Migration[7.0]
  def up
    add_column :article_categories, :deleted_at, :datetime
    add_index :article_categories, :deleted_at

    reassign_orphaned_article_versions
  end

  def down
    remove_column :article_categories, :deleted_at, :datetime
  end

  private

  def reassign_orphaned_article_versions
    first_article_category = select_one('SELECT id FROM article_categories LIMIT 1')

    return if first_article_category.nil?

    update(%(
        UPDATE article_versions
        SET article_category_id = #{quote first_article_category['id']}
        WHERE article_category_id NOT IN (SELECT id FROM article_categories)
      ))
  end
end
