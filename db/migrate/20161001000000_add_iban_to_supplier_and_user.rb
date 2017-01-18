class AddIbanToSupplierAndUser < ActiveRecord::Migration
  def change
    add_column :suppliers, :iban, :string
    add_column :users, :iban, :string
  end
end
