class CreateBankGateways < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_gateways do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :authorization
      t.integer :unattended_user_id
    end

    add_reference :bank_accounts, :bank_gateway
  end
end
