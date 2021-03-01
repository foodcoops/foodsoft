class CreateTasks < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tasks do |t|
      t.column :name, :string, :null => false
      t.column :description, :string
      t.column :due_date, :date
      t.column :done, :boolean, :default => false
      t.column :group_id, :integer
      t.column :assigned, :boolean, :default => false
      t.column :created_on, :datetime, :null => false
      t.column :updated_on, :datetime, :null => false
    end
    add_index :tasks, :name
    add_index :tasks, :due_date

    create_table :assignments do |t|
      t.column :user_id, :integer, :null => false
      t.column :task_id, :integer, :null => false
      t.column :accepted, :boolean, :default => false
    end
    add_index :assignments, [:user_id, :task_id], :unique => true

    add_column :groups, :weekly_task, :boolean, :default => false # if group has an job for every week
    add_column :groups, :weekday, :integer  # e.g. 1 means monday, 2 = tuesday an so on
    add_column :groups, :task_name, :string # the name of the weekly task
    add_column :groups, :task_description, :string
  end

  def self.down
    drop_table :tasks
    drop_table :assignments
    remove_column :groups, :weekly_task
    remove_column :groups, :weekday
    remove_column :groups, :task_name
    remove_column :groups, :task_description
  end
end
