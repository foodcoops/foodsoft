class AddLastActivityToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_activity, :datetime
  end
end
