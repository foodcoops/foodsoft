class AddBreakToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :break_start, :date
    add_column :groups, :break_end, :date
  end
end
