class AddArticleInfoUrl < ActiveRecord::Migration
  def self.up
    add_column :articles, :info_url, :string
    add_column :suppliers, :article_info_url, :string
  end

  def self.down
    remove_column :suppliers, :article_info_url, :string
    remove_column :articles, :info_url
  end
end
