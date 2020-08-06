class RemoveAssignedFromTasks < ActiveRecord::Migration[4.2]
  def up
    remove_column :tasks, :assigned
  end

  def down
    add_column :tasks, :assigned, :boolean
  end
end
