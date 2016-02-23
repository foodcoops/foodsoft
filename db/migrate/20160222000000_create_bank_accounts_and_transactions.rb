class CreateBankAccountsAndTransactions < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name, :null => false
      t.string :iban
      t.string :description
      t.decimal :balance, :precision => 12, :scale => 2, :null => false
      t.datetime :last_import
    end

    create_table :bank_transactions do |t|
      t.references :bank_account, :null => false
      t.string :import_id
      t.date :booking_date
      t.date :value_date
      t.decimal :amount, :precision => 8, :scale => 2, :null => false
      t.string :booking_type
      t.string :iban
      t.string :reference
      t.text :text
      t.text :receipt
      t.binary :image, :limit => 1.megabyte
    end
  end
end
