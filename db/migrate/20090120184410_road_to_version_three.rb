
class OrderGroup < Group; end # Needed for renaming of OrderGroup to Ordergroup

class RoadToVersionThree < ActiveRecord::Migration[4.2]
  def self.up
    # TODO: Combine migrations since foodsoft3-development into one file
    # and try to build a migration path from old data.

    # == Message
    drop_table :messages
    create_table :messages do |t|
      t.references :sender
      t.text :recipients_ids
      t.string :subject, :null => false
      t.text :body
      t.integer :email_state, :default => 0, :null => false
      t.boolean :private, :default => false
      t.datetime :created_at
    end

    # Acts_as_paranoid
    add_column :suppliers, :deleted_at, :datetime
    add_column :articles, :deleted_at, :datetime
    add_column :groups, :deleted_at, :datetime

    # == Workgroups
    puts "Migrate all groups to workgroups.."
    Group.find(:all, :conditions => { :type => "" }).each do |workgroup|
      workgroup.update_attribute(:type, "Workgroup")
    end

    # == Ordergroups
    remove_column :groups, :actual_size        # Useless, desposits are better stored within a transaction.note
    # rename from OrderGroup to Ordergroup
    rename_column :financial_transactions, :order_group_id, :ordergroup_id
    rename_column :group_orders, :order_group_id, :ordergroup_id
    rename_column :tasks, :group_id, :workgroup_id
    remove_index :group_orders, :name => "index_group_orders_on_order_group_id_and_order_id"
    add_index :group_orders, [:ordergroup_id, :order_id], :unique => true

    Group.find(:all, :conditions => { :type => "OrderGroup" }).each do |ordergroup|
      ordergroup.update_attribute(:type, "Ordergroup")
    end
    # move contact-infos from users to ordergroups
    add_column :groups, :contact_person, :string
    add_column :groups, :contact_phone, :string
    add_column :groups, :contact_address, :string
    Ordergroup.all.each do |ordergroup|
      contact = ordergroup.users.first
      if contact
        ordergroup.update_attributes :contact_person => contact.name,
          :contact_phone => contact.phone, :contact_address => contact.address
      end
    end
    remove_column :users, :address

    # == Order
    drop_table :orders
    drop_table :group_order_results
    drop_table :order_article_results
    drop_table :group_order_article_results
    GroupOrder.delete_all; OrderArticle.delete_all; GroupOrderArticle.delete_all; GroupOrderArticleQuantity.delete_all

    create_table :orders do |t|
      t.references :supplier
      t.text :note
      t.datetime :starts
      t.datetime :ends
      t.string :state, :default => "open"   # Statemachine ... open -> finished -> closed
      t.integer :lock_version, :default => 0, :null => false
      t.integer :updated_by_user_id
    end

    # == Invoice
    create_table :invoices do |t|
      t.references :supplier
      t.references :delivery
      t.references :order
      t.string :number
      t.date :date
      t.date :paid_on
      t.text :note
      t.decimal :amount, :null => false, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :deposit, :precision => 8, :scale => 2, :default => 0.0,  :null => false
      t.decimal :deposit_credit, :precision => 8, :scale => 2, :default => 0.0,  :null => false
      t.timestamps
    end

    # == Delivery
     create_table :deliveries do |t|
      t.integer :supplier_id
      t.date :delivered_on
      t.datetime :created_at
    end

    # == Comment
    drop_table :comments
    create_table :order_comments do |t|
      t.references :order
      t.references :user
      t.text :text
      t.datetime :created_at
    end

    # == Article
    rename_column :articles, :net_price, :price
    remove_column :articles, :gross_price

    # == ArticlePrice
    create_table :article_prices do |t|
      t.references :article
      t.decimal :price, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :tax, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :deposit, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.integer :unit_quantity
      t.datetime :created_at
    end
    # Create price history for every Article
    Article.all.each do |a|
      a.article_prices.create :price => a.price, :tax => a.tax,
        :deposit => a.deposit, :unit_quantity => a.unit_quantity
    end
    # Every Article has now a Category. Fix it if neccessary.
    Article.all(:conditions => { :article_category_id => nil }).each do |article|
        article.update_attribute(:article_category, ArticleCategory.first)
    end
    # order-articles
    add_column :order_articles, :article_price_id, :integer

    # == GroupOrder
    change_column :group_orders, :updated_by_user_id, :integer, :default => nil, :null => true

    # == GroupOrderArticle
    # The total order result in ordergroup is now saved!
    add_column :group_order_articles, :result, :integer, :default => nil

    # == StockArticle
    add_column :articles, :type, :string
    add_column :articles, :quantity, :integer, :default => 0

    # == StockChanges
    create_table :stock_changes do |t|
      t.references :delivery
      t.references :order
      t.references :stock_article
      t.integer :quantity, :default => 0
      t.datetime :created_at
    end

    # == StockTaking
    create_table :stock_takings do |t|
      t.date :date
      t.text :note
      t.datetime :created_at
    end
    add_column :stock_changes, :stock_taking_id, :integer

    # == User
    # Ativate all Users for notification on upcoming tasks
    User.all.each { |u| u.settings['notify.upcoming_tasks'] = 1 }
  end

  def self.down
  end
end
