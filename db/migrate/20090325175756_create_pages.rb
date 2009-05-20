class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.string :permalink
      t.integer :lock_version, :default => 0
      t.integer :updated_by

      t.timestamps
    end
    
    Page.create_versioned_table # Automaticly creates pages_versions table
  end

  def self.down
    drop_table :pages
    Page.drop_versioned_table
  end
end
