class AddMaximumOrderQuantityToArticleVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :article_versions, :maximum_order_quantity, :float
  end
end
