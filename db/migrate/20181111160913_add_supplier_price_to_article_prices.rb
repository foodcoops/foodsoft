class AddSupplierPriceToArticlePrices < ActiveRecord::Migration
  def change
    add_column :article_prices, :supplier_price, :decimal, :precision => 8, :scale => 2
  end
end
