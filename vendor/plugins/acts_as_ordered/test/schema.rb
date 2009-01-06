ActiveRecord::Schema.define :version => 0 do
  create_table :cartoons, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name,  :string
  end
  
  create_table :categories, :force => true do |t|
    t.column :name, :string 
  end
  
  create_table :projects, :force => true do |t|
    t.column :category_id, :integer
    t.column :name,        :string  
    t.column :description, :string
  end
  
  create_table :documents, :force => true do |t|
    t.column :title, :string
    t.column :type, :string
  end
end
