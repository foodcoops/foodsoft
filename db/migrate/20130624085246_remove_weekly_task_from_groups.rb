class RemoveWeeklyTaskFromGroups < ActiveRecord::Migration[4.2]
  def up
    remove_column :groups, :weekly_task
    remove_column :groups, :weekday
    remove_column :groups, :task_name
    remove_column :groups, :task_description
    remove_column :groups, :task_required_users
    remove_column :groups, :task_duration
  end

  def down
    add_column :groups, :task_duration, :integer
    add_column :groups, :task_required_users, :integer
    add_column :groups, :task_description, :string
    add_column :groups, :task_name, :string
    add_column :groups, :weekday, :integer
    add_column :groups, :weekly_task, :boolean
  end
end
