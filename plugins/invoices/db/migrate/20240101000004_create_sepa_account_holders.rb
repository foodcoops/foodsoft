class CreateSepaAccountHolders < ActiveRecord::Migration[7.0]
  def change
    create_table :sepa_account_holders do |t|
      t.references :user, null: false
      t.references :group, null: false

      t.string :iban
      t.string :bic
      t.string :mandate_id
      t.date :mandate_date_of_signature
      t.timestamps
    end
  end
end
