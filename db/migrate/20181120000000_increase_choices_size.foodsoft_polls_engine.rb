class IncreaseChoicesSize < ActiveRecord::Migration
  def up
    change_column :polls, :choices, :text, limit: 65535
  end
end
