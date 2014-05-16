class AddPriceMarkupToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :price_markup_key, :string
  end
end
