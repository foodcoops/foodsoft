class AddWeightToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :weight, :number
  end
end
