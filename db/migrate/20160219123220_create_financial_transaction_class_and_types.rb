class CreateFinancialTransactionClassAndTypes < ActiveRecord::Migration
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

    execute "INSERT INTO financial_transaction_classes (id, name) VALUES (1, '')"
    execute "INSERT INTO financial_transaction_types (id, name, financial_transaction_class_id) VALUES (1, 'Foodsoft', 1)"
    execute "UPDATE financial_transactions SET financial_transaction_type_id = 1"

    change_column_null :financial_transactions, :financial_transaction_type_id, false
  end
end
