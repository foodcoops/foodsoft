class AddSyncSkipColumnsToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :sync_skip_columns, :string
  end
end
