class DeleteEmptyGroupOrderArticles < ActiveRecord::Migration
  def up
    # up until recently, group_order_articles with all quantities zero were saved
    GroupOrderArticle.where(quantity: 0, tolerance: 0, result: [0, nil], result_computed: [0, nil]).delete_all
  end

  def down
  end
end
