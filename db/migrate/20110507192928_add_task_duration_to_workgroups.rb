class AddTaskDurationToWorkgroups < ActiveRecord::Migration[4.2]
  def self.up
    add_column :groups, :task_duration, :integer, :default => 1
  end

  def self.down
    remove_column :groups, :task_duration
  end
end
