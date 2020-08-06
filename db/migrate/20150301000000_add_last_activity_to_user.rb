class AddLastActivityToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_activity, :datetime
  end
end
