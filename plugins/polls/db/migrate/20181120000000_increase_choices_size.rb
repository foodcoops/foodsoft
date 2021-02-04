class IncreaseChoicesSize < ActiveRecord::Migration[4.2]
  def up
    change_column :polls, :choices, :text, limit: 65535
  end
end
