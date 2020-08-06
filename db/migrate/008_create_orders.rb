class CreateOrders < ActiveRecord::Migration[4.2]
  ORDER_TEST = 'Test Order'
  GROUP_ORDER = 'Orders'
  
  def self.up
    # Order role
    add_column :groups, :role_orders, :boolean, :default => false, :null => false
    Group.reset_column_information
    puts "Give #{CreateGroups::GROUP_ADMIN} the role finance .."
    raise "Failed" unless Group.find_by_name(CreateGroups::GROUP_ADMIN).update_attribute(:role_orders, true)
    raise 'Cannot find admin user!' unless admin = User.find_by_nick(CreateUsers::USER_ADMIN)
    raise 'Failed to enable role_orders with admin user!' unless admin.role_orders?
    
    # Create the default "Order" group...
    puts 'Creating group "Orders"...'
    Group.create(:name => GROUP_ORDER, :description => "working group for managing orders", :role_orders => true)
    raise "Failed!" unless Group.find_by_name(GROUP_ORDER)
  
    # Order
    create_table :orders do |t|
      t.column :name, :string, :null => false
      t.column :supplier_id, :integer, :null => false
      t.column :starts, :datetime, :null => false
      t.column :ends, :datetime
      t.column :note, :string
      t.column :finished, :boolean, :default => false, :null => false
      t.column :booked, :boolean, :null => false, :default => false
      t.column :lock_version, :integer, :null => false, :default => 0
      t.column :updated_by_user_id, :integer
    end
    add_index(:orders, :starts)
    add_index(:orders, :ends)
    add_index(:orders, :finished)
    
    puts "Creating order '#{ORDER_TEST}'..."
    raise "Supplier '#{CreateSuppliers::SUPPLIER_SAMPLE}' not found!" unless supplier = Supplier.find_by_name(CreateSuppliers::SUPPLIER_SAMPLE)
    Order.create(:name => ORDER_TEST, :supplier => supplier, :starts => Time.now)
    raise 'Creating test order failed!' unless order = Order.find_by_name(ORDER_TEST)

    # OrderArticle
    create_table :order_articles do |t|
      t.column :order_id, :integer, :null => false
      t.column :article_id, :integer, :null => false
      t.column :quantity, :integer, :null => false, :default => 0
      t.column :tolerance, :integer, :null => false, :default => 0
      t.column :units_to_order, :integer, :null => false, :default => 0
      t.column :lock_version, :integer, :null => false, :default => 0
    end
    add_index(:order_articles, [:order_id, :article_id], :unique => true)
    
    puts 'Adding articles to the order...'
    CreateArticles::SAMPLE_ARTICLE_NAMES.each  { | a | 
        puts "Article #{a}..."
        raise 'Article not found!' unless article = Article.find_by_name(a)
        raise 'No price found for article!' unless price = article.current_price
        OrderArticle.create(:order => order, :article => article)
        raise 'Creating OrderArticle failed!' unless OrderArticle.find_by_order_id_and_article_id(order.id, article.id)
     }    
     raise 'Creating OrderArticles failed!' unless order.articles.size == CreateArticles::SAMPLE_ARTICLE_NAMES.length
    
    # GroupOrder
    create_table :group_orders do |t|
      t.column :order_group_id, :integer, :null => false
      t.column :order_id, :integer, :null => false
      t.column :price, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
      t.column :lock_version, :integer, :null => false, :default => 0
      t.column :updated_on, :timestamp, :null => false
      t.column :updated_by_user_id, :integer, :null => false
    end
    add_index(:group_orders, [:order_group_id, :order_id], :unique => true)  
    
    puts 'Adding group order...'
    raise "Cannot find user #{CreateUsers::USER_TEST}" unless user = User.find_by_nick(CreateUsers::USER_TEST)
    raise "Cannot find OrderGroup '#{CreateGroups::GROUP_ORDER}'!" unless orderGroup = OrderGroup.find_by_name(CreateGroups::GROUP_ORDER)
    GroupOrder.create(:order_group => orderGroup, :order => order, :price => 0, :updated_by => user)
    raise 'Retrieving group order failed!' unless groupOrder = orderGroup.group_orders.find(:first, :conditions => "order_id = #{order.id}")
        
    # GroupOrderArticles
    create_table :group_order_articles do |t|
      t.column :group_order_id, :integer, :null => false
      t.column :order_article_id, :integer, :null => false
      t.column :quantity, :integer, :null => false
      t.column :tolerance, :integer, :null => false
      t.column :updated_on, :timestamp, :null => false
    end    
    add_index(:group_order_articles, [:group_order_id, :order_article_id], :unique => true, :name => "goa_index")
    # GroupOrderArticleQuantity
    create_table :group_order_article_quantities do |t|
      t.column :group_order_article_id, :int, :null => false
      t.column :quantity, :int, :default => 0
      t.column :tolerance, :int, :default => 0
      t.column :created_on, :timestamp, :null => false
    end
    
    puts 'Adding articles to group order...'
    order.order_articles.each { | orderArticle |
      puts "Article #{orderArticle.article.name}..."
      GroupOrderArticle.create(:group_order => groupOrder, :order_article => orderArticle, :quantity => 0, :tolerance => 0)
      raise 'Failed to create order!' unless article = GroupOrderArticle.find(:first, :conditions => "group_order_id = #{groupOrder.id} AND order_article_id = #{orderArticle.id}")
      article.updateQuantities(rand(6) + 1, rand(4) + 1)
    }
    raise 'Failed to create orders!' unless groupOrder.order_articles.size == order.order_articles.size    
    groupOrder.updatePrice
    raise 'Failed to update GroupOrder.price' unless groupOrder.save!    
    
    # Update order
    order.updateQuantities    
  end

  def self.down
    remove_column :groups, :role_orders
    drop_table :orders
    drop_table :order_articles
    drop_table :group_orders
    drop_table :group_order_articles
    drop_table :group_order_article_quantities
  end
end
