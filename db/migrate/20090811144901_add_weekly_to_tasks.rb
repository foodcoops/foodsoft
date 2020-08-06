class AddWeeklyToTasks < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tasks, :weekly, :boolean
  end

  def self.down
    remove_column :tasks, :weekly
  end
end
