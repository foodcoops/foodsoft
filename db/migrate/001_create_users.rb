class CreateUsers < ActiveRecord::Migration[4.2]
  USER_ADMIN = 'admin'
  USER_TEST = 'test'

  def self.up
    create_table :users do |t|
      t.column :nick, :string, :null => false
      t.column :password_hash, :string, :null => false
      t.column :password_salt, :string, :null => false
      t.column :first_name, :string, :null => false
      t.column :last_name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :phone, :string
      t.column :address, :string
      t.column :created_on, :timestamp, :null => false
    end
    add_index(:users, :nick, :unique => true)
    add_index(:users, :email, :unique => true)

    # Create the default admin user...
    puts "Creating user #{USER_ADMIN} with password 'secret'..."
    user = User.new(:nick => USER_ADMIN, :first_name => "Anton", :last_name => "Administrator", :email => "admin@foo.test")
    user.password = "secret"
    raise "Failed!" unless user.save && User.find_by_nick(USER_ADMIN).has_password("secret")

    # Create a normal user...
    puts "Creating user #{USER_TEST} with password 'foobar'..."
    user = User.new(:nick => USER_TEST, :first_name => "Tim", :last_name => "Tester", :email => "test@foo.test")
    user.password = "foobar"
    raise "Failed!" unless user.save && User.find_by_nick(USER_TEST).has_password("foobar")
  end

  def self.down
    drop_table :users
  end
end
