ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 0) do
  
  create_table :configurable_settings, :force => true do |t|
    t.column :configurable_id, :integer
    t.column :configurable_type, :string
    t.column :targetable_id, :integer
    t.column :targetable_type, :string
    t.column :name, :string, :default => "", :null => false
    t.column :value_type, :string
    t.column :value, :text
  end
  add_index :configurable_settings, :name

  create_table :test_groups, :force => true do |t|
    t.column :display_name, :string, :limit => 80
  end

  create_table :test_users, :force => true do |t|
    t.column :login, :string, :limit => 20
    t.column :name, :string, :limit => 80
    t.column :email, :string
  end
  
end

ActiveRecord::Migration.verbose = true