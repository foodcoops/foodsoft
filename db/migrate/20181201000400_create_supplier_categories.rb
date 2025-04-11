class CreateSupplierCategories < ActiveRecord::Migration[4.2]
  class FinancialTransactionClass < ActiveRecord::Base; end

  class SupplierCategory < ActiveRecord::Base; end

  class Supplier < ActiveRecord::Base; end

  def change
    create_table :supplier_categories do |t|
      t.string :name, null: false
      t.string :description
      t.references :financial_transaction_class, null: false
    end

    add_reference :suppliers, :supplier_category

    reversible do |dir|
      dir.up do
        ftc = FinancialTransactionClass.first
        sc = SupplierCategory.create name: 'Other', financial_transaction_class_id: ftc.id
        Supplier.update_all supplier_category_id: sc.id
      end
    end

    change_column_null :suppliers, :supplier_category_id, false
  end
end
