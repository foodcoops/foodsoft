class AddDurationToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :duration, :integer
  end

  def self.down
    remove_column :tasks, :duration
  end
end
