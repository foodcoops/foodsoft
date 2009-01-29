class ActsAsParanoid < ActiveRecord::Migration
  def self.up
    add_column :suppliers, :deleted_at, :datetime
    add_column :articles, :deleted_at, :datetime
  end

  def self.down
    remove_column :suppliers, :deleted_at
    remove_column :articles, :deleted_at
  end
end
