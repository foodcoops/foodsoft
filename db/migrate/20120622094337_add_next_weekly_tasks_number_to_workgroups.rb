class AddNextWeeklyTasksNumberToWorkgroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :next_weekly_tasks_number, :integer, :default => 8
  end

  def self.down
    remove_column :groups, :next_weekly_tasks_number
  end
end
