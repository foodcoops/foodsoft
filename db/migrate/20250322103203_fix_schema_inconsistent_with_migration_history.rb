class FixSchemaInconsistentWithMigrationHistory < ActiveRecord::Migration[7.0]
  def up
    update(%(
        UPDATE suppliers
        SET suppliers.supplier_category_id = (SELECT id FROM supplier_categories LIMIT 1)
        WHERE suppliers.supplier_category_id IS NULL
    ))
    change_column_null :suppliers, :supplier_category_id, false
    change_column :article_versions, :created_at, :datetime
  end

  def down
    change_column_null :suppliers, :supplier_category_id, true
    change_column :article_versions, :created_at, :datetime, precision: nil
  end
end
