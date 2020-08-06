class AddIgnoreAppleRestrictionToGroups < ActiveRecord::Migration[4.2]
  def self.up
    add_column :groups, :ignore_apple_restriction, :boolean, default: false
  end

  def self.down
    remove_column :groups, :ignore_apple_restriction
  end
end
