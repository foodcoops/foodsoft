class CreateArticles < ActiveRecord::Migration[4.2]
  SAMPLE_ARTICLE_NAMES = ['banana', 'kiwi', 'strawberry']

  def self.up
    create_table :articles do |t|
      t.column :name, :string, :null => false
      t.column :supplier_id, :integer, :null => false
      t.column :article_category_id, :integer, :null => false
      t.column :unit, :string, :null => false
      t.column :note, :string
      t.column :availability, :boolean, :default => true, :null => false
      t.column :current_price_id, :integer
    end
    add_index(:articles, :name, :unique => true)

    # Create 30 sample articles...
    puts "Create 3 articles of the supplier '#{CreateSuppliers::SUPPLIER_SAMPLE}'..."
    raise "Supplier '#{CreateSuppliers::SUPPLIER_SAMPLE}' not found!" unless supplier = Supplier.find_by_name(CreateSuppliers::SUPPLIER_SAMPLE)
    raise "Category '#{CreateArticleMeta::CATEGORY_SAMPLE}' not found!" unless category = ArticleCategory.find_by_name(CreateArticleMeta::CATEGORY_SAMPLE)

    SAMPLE_ARTICLE_NAMES.each do |a|
      puts 'Create Article ' + a
      Article.create(:name => a,
                     :supplier => supplier,
                     :article_category => category,
                     :unit => '500g',
                     :note => 'delicious',
                     :availability => true)
    end
    raise "Failed!" unless Article.find(:all).length == SAMPLE_ARTICLE_NAMES.length
  end

  def self.down
    drop_table :articles
  end
end
