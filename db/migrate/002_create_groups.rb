class CreateGroups < ActiveRecord::Migration[4.2]
  GROUP_ADMIN = 'Administrators'
  GROUP_ORDER = 'Sample Order Group'

  def self.up
    create_table :groups do |t|
      t.column :type, :string, :null => false # inheritance, types: Group, OrderGroup
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :actual_size, :integer # OrderGroup column
      t.column :account_balance, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0 # OrderGroup column
      t.column :account_updated, :timestamp # OrderGroup column
      t.column :created_on, :timestamp, :null => false
      t.column :role_admin, :boolean, :default => false, :null => false
    end
    add_index(:groups, :name, :unique => true)

    create_table :memberships do |t|
      t.column :group_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    add_index(:memberships, [:user_id, :group_id], :unique => true)

    # Create the default "Administrators" group...
    puts "Creating group #{GROUP_ADMIN}..."
    Group.create(:name => GROUP_ADMIN, :description => "System administrators.", :role_admin => true)
    raise 'Failed!' unless administrators = Group.find_by_name(GROUP_ADMIN)

    # Create a sample order group...
    puts "Creating order group #{GROUP_ORDER}..."
    ordergroup = OrderGroup.create!(:name => GROUP_ORDER, :description => "A sample order group created by the migration.", :actual_size => 1, :account_updated => Time.now)
    raise "Wrong type created!" unless ordergroup.is_a?(OrderGroup)

    # Get the admin user and join the admin group...
    raise "User #{CreateUsers::USER_ADMIN} not found, cannot join group '#{administrators.name}'!" unless admin = User.find_by_nick(CreateUsers::USER_ADMIN)

    puts "Joining #{CreateUsers::USER_ADMIN} user to new '#{administrators.name}' group as a group admin..."
    membership = Membership.create(:group => administrators, :user => admin)
    raise "Failed!" unless admin.memberships.first == membership
    raise "User #{CreateUsers::USER_ADMIN} has no admin_roles" unless admin.role_admin?

    # Get the test user and join the order group...
    raise "User #{CreateUsers::USER_TEST} not found, cannot join group '#{ordergroup.name}'!" unless test = User.find_by_nick(CreateUsers::USER_TEST)

    puts "Joining #{CreateUsers::USER_TEST} user to new '#{ordergroup.name}' group as a group admin..."
    membership = Membership.create(:group => ordergroup, :user => test)
    raise "Failed!" unless test.memberships.first == membership
  end

  def self.down
    drop_table :groups
    drop_table :memberships
  end
end
