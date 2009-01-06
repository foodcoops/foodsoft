class RemoveUniquenessOfArticleName < ActiveRecord::Migration
  def self.up
    remove_index :articles, :name
    add_index :articles, [:name, :supplier_id]
  end

  def self.down
    remove_index :articles, [:name, :supplier_id]
    add_index :articles, :name, :unique => true
  end
end
