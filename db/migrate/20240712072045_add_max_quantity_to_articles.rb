class AddMaxQuantityToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :max_quantity, :integer
  end
end
