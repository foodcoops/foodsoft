class ChangeMarkedAsDeletedNames < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE groups SET name = REPLACE(name, '\\u2020', '\u2020') WHERE deleted_at IS NOT NULL"
    execute "UPDATE suppliers SET name = REPLACE(name, '\\u2020', '\u2020') WHERE deleted_at IS NOT NULL"
  end
end
