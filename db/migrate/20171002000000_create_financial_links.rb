class CreateFinancialLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :financial_links do |t|
      t.text :note
    end

    add_column :financial_transactions, :financial_link_id, :integer, index: true
    add_column :invoices, :financial_link_id, :integer, index: true
  end
end
