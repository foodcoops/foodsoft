class AddWeeklyToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :weekly, :boolean
  end

  def self.down
    remove_column :tasks, :weekly
  end
end
