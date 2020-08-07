class CreateBankAccountsAndTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_accounts do |t|
      t.string :name, null: false
      t.string :iban
      t.string :description
      t.decimal :balance, precision: 12, scale: 2, default: 0, null: false
      t.datetime :last_import
      t.string :import_continuation_point
    end

    create_table :bank_transactions do |t|
      t.references :bank_account, null: false
      t.string :external_id
      t.date :date
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :iban
      t.string :reference
      t.text :text
      t.text :receipt
      t.binary :image, limit: 1.megabyte
      t.references :financial_link, index: true
    end
  end
end
