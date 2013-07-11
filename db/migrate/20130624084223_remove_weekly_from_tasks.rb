class RemoveWeeklyFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :weekly
  end

  def down
    add_column :tasks, :weekly, :boolean
  end
end
