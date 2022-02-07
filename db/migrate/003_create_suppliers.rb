class CreateSuppliers < ActiveRecord::Migration[4.2]
  SUPPLIER_SAMPLE = 'Sample Supplier'

  def self.up
    add_column :groups, :role_suppliers, :boolean, :default => false, :null => false
    Group.reset_column_information
    puts "Give #{CreateGroups::GROUP_ADMIN} the role supplier .."
    raise "Failed" unless Group.find_by_name(CreateGroups::GROUP_ADMIN).update_attribute(:role_suppliers, true)
    raise "Cannot find admin user!" unless admin = User.find_by_nick(CreateUsers::USER_ADMIN)
    raise "Failed to enable role_suppliers with admin user!" unless admin.role_suppliers?

    create_table :suppliers do |t|
      t.column :name, :string, :null => false
      t.column :address, :string, :null => false
      t.column :phone, :string, :null => false
      t.column :phone2, :string
      t.column :fax, :string
      t.column :email, :string
      t.column :url, :string
      t.column :contact_person, :string
      t.column :customer_number, :string
      t.column :delivery_days, :string
      t.column :order_howto, :string
      t.column :note, :string
    end
    add_index(:suppliers, :name, :unique => true)

    # Create sample supplier...
    puts "Creating sample supplier '#{SUPPLIER_SAMPLE}'..."
    Supplier.create(:name => SUPPLIER_SAMPLE, :address => "Organic City", :phone => "0123-555555")
    raise "Failed!" unless supplier = Supplier.find_by_name(SUPPLIER_SAMPLE)
  end

  def self.down
    remove_column :groups, :role_suppliers
    drop_table :suppliers
  end
end
