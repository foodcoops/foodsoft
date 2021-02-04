class CreateFinancialTransactionClassAndTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :financial_transaction_classes do |t|
      t.string :name, :null => false
    end

    create_table :financial_transaction_types do |t|
      t.string :name, :null => false
      t.references :financial_transaction_class, :null => false
    end

    change_table :financial_transactions do |t|
      t.references :financial_transaction_type
    end

    reversible do |dir|
      dir.up do
        execute "INSERT INTO financial_transaction_classes (id, name) VALUES (1, 'Standard')"
        execute "INSERT INTO financial_transaction_types (id, name, financial_transaction_class_id) VALUES (1, 'Foodsoft', 1)"
        execute "UPDATE financial_transactions SET financial_transaction_type_id = 1"
      end
    end

    change_column_null :financial_transactions, :financial_transaction_type_id, false
  end
end
