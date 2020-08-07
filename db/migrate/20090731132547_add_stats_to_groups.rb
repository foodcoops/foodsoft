class AddStatsToGroups < ActiveRecord::Migration[4.2]
  def self.up
    add_column :groups, :stats, :text

    Ordergroup.all.each { |o| o.update_stats! }
  end

  def self.down
    remove_column :groups, :stats
  end
end
