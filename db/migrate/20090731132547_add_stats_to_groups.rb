class AddStatsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :stats, :text

    Ordergroup.all.each { |o| o.update_stats! }
  end

  def self.down
    remove_column :groups, :stats
  end
end
