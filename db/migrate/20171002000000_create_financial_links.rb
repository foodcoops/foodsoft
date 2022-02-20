class CreateFinancialLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :financial_links do |t|
      t.text :note
    end

    add_column :financial_transactions, :financial_link_id, :integer
    add_column :invoices, :financial_link_id, :integer

    add_index :financial_transactions, :financial_link_id
    add_index :invoices, :financial_link_id
  end
end
