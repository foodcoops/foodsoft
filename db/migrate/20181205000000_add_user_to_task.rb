class AddUserToTask < ActiveRecord::Migration[4.2]
  def change
    add_column :tasks, :created_by_user_id, :integer

    reversible do |dir|
      dir.up do
        change_column :tasks, :description, :text
      end
    end
  end
end
