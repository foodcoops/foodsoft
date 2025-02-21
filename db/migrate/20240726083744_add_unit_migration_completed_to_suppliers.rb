class AddUnitMigrationCompletedToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :suppliers, :unit_migration_completed, :datetime
  end
end
