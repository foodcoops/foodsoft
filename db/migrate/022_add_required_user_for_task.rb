class AddRequiredUserForTask < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tasks, :required_users, :integer, :default => 1
    add_column :groups, :task_required_users, :integer, :default => 1
    # add default values to every task and group
    Task.find(:all).each { |task| task.update_attribute :required_users, 1 }
    Group.workgroups.each { |group| group.update_attribute :task_required_users, 1 }
  end

  def self.down
    remove_column :tasks, :required_users
    remove_column :groups, :tasks_required_users
  end
end
