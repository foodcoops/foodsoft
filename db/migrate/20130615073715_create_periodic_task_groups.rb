class CreatePeriodicTaskGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :periodic_task_groups do |t|
      t.date :next_task_date

      t.timestamps
    end

    change_table :tasks do |t|
      t.references :periodic_task_group
    end
  end
end
