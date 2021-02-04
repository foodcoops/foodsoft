class CreateFinancialTransactions < ActiveRecord::Migration[4.2]
  def self.up
    # Create Financial Transactions
    create_table :financial_transactions do |t|
      t.column :order_group_id, :integer, :null => false
      t.column :amount, :decimal, :precision => 8, :scale => 2, :null => false
      t.column :note, :text, :null => false
      t.column :user_id, :integer, :null => false
      t.column :created_on, :datetime, :null => false
    end

    # add column for the finance role
    puts 'add column in "groups" for the finance role'
    add_column :groups, :role_finance, :boolean, :default => false, :null => false
    Group.reset_column_information
    puts "Give #{CreateGroups::GROUP_ADMIN} the role finance .."
    raise "Failed" unless Group.find_by_name(CreateGroups::GROUP_ADMIN).update_attribute(:role_finance, true)
    raise 'Cannot find admin user!' unless admin = User.find_by_nick(CreateUsers::USER_ADMIN)
    raise 'Failed to enable role_finance with admin user!' unless admin.role_finance?

    # Add transactions to the sample order group
    puts "Add 30 transactions to the group '#{CreateGroups::GROUP_ORDER}'..."
    raise "Group '#{CreateGroups::GROUP_ORDER}' not found!" unless ordergroup = Group.find_by_name(CreateGroups::GROUP_ORDER)
    balance = 0
    for i in 1..30
      ordergroup.addFinancialTransaction(i, "Sample Transaction Nr. #{i}", admin)
      balance += i
    end
    raise "Failed!" unless financial_transaction = FinancialTransaction.find_by_note('Sample Transaction Nr. 1')  
    raise "Failed to update account_balance!" unless OrderGroup.find(ordergroup.id).account_balance == balance
  
  end
  
  def self.down
    remove_column :groups, :role_finance
    drop_table :financial_transactions
  end
end
