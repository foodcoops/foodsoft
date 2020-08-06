class CreatePages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.string :permalink
      t.integer :lock_version, :default => 0
      t.integer :updated_by
      t.integer :redirect
      t.integer :parent_id

      t.timestamps
    end
    add_index :pages, :title
    add_index :pages, :permalink
    Page.create_versioned_table # Automaticly creates pages_versions table
  end

  def self.down
    drop_table :pages
    Page.drop_versioned_table
  end
end
