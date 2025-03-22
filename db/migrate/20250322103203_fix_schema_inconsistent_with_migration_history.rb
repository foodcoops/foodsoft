class FixSchemaInconsistentWithMigrationHistory < ActiveRecord::Migration[7.0]
  def up
    change_column :article_versions, :created_at, :datetime
  end

  def down
    change_column :article_versions, :created_at, :datetime, precision: nil
  end

  def change
    change_column_null :suppliers, :supplier_category_id, false
  end
end
