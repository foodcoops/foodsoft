class RemoveWeeklyFromTasks < ActiveRecord::Migration[4.2]
  def up
    remove_column :tasks, :weekly
  end

  def down
    add_column :tasks, :weekly, :boolean
  end
end
