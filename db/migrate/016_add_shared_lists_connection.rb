class AddSharedListsConnection < ActiveRecord::Migration[4.2]
  def self.up
    add_column :suppliers, :shared_supplier_id, :integer
    add_column :articles, :manufacturer , :string
    add_column :articles, :origin, :string
    add_column :articles, :shared_updated_on, :timestamp
  end

  def self.down
    remove_column :suppliers, :shared_supplier_id
    remove_column :articles, :manufacturer
    remove_column :articles, :origin
    remove_column :articles, :shared_updated_on
  end
end
