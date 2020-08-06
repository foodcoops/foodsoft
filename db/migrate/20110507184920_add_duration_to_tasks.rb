class AddDurationToTasks < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tasks, :duration, :integer, :default => 1
  end

  def self.down
    remove_column :tasks, :duration
  end
end
