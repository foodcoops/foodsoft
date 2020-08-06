class CreateArticleMeta < ActiveRecord::Migration[4.2]
  CATEGORY_SAMPLE = 'Sample Category'
  TAX_STANDARD = 'Standard'
  TAX_REDUCED = 'Reduced'
  
  def self.up
    # Add user roles...
    add_column :groups, :role_article_meta, :boolean, :default => false, :null => false    
    Group.reset_column_information
    puts "Give #{CreateGroups::GROUP_ADMIN} the role article_meta .."
    raise "Failed" unless Group.find_by_name(CreateGroups::GROUP_ADMIN).update_attribute(:role_article_meta, true)
    raise 'Cannot find admin user!' unless admin = User.find_by_nick(CreateUsers::USER_ADMIN)
    raise 'Failed to enable role_article_meta with admin user!' unless admin.role_article_meta?
    
    # ArticleCategories
    create_table :article_categories do |t|
      t.column :name, :string, :null => false
      t.column :description, :string
    end
    add_index(:article_categories, :name, :unique => true)
    
    # Create sample category...
    puts "Creating sample article category '#{CATEGORY_SAMPLE}'..."
    ArticleCategory.create(:name => CATEGORY_SAMPLE, :description => "This is just a sample article category.")
    raise "Failed!" unless category = ArticleCategory.find_by_name(CATEGORY_SAMPLE)        
           
  end

  def self.down
    remove_column :groups, :role_article_meta
    drop_table :article_categories
  end
end
