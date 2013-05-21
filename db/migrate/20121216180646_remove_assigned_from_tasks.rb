class RemoveAssignedFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :assigned
  end

  def down
    add_column :tasks, :assigned, :boolean
  end
end
