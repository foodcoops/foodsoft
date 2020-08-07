class AllowMissingNick < ActiveRecord::Migration[4.2]
  def self.up
    change_column :users, :nick, :string, :default => nil, :null => true
  end

  def self.down
    change_column :users, :nick, :string, :default => "", :null => false
  end
end
