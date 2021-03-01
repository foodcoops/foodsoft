class CreateOrderResults < ActiveRecord::Migration[4.2]
  def self.up
    create_table :group_order_results do |t|
      t.column :order_id, :int, :null => false
      t.column :group_name, :string, :null => false
      t.column :price, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0
    end
    add_index(:group_order_results, [:group_name, :order_id], :unique => true)

    create_table :order_article_results do |t|
      t.column :order_id, :int, :null => false
      t.column :name, :string, :null => false
      t.column :unit, :string, :null => false
      t.column :note, :string
      t.column :clear_price, :decimal, :precision => 8, :scale => 2, :null => false
      t.column :gross_price, :decimal, :precision => 8, :scale => 2, :null => false
      t.column :tax, :float, :null => false, :default => 0
      t.column :refund, :decimal, :precision => 8, :scale => 2
      t.column :fc_markup, :float, :null => false
      t.column :order_number, :string
      t.column :unit_quantity, :int, :null => false
      t.column :units_to_order, :int, :null => false
    end
    add_index(:order_article_results, :order_id)

    create_table :group_order_article_results do |t|
      t.column :order_article_result_id, :int, :null => false
      t.column :group_order_result_id, :int, :null => false
      t.column :quantity, :int, :null => false
      t.column :tolerance, :int
    end
    add_index(:group_order_article_results, :order_article_result_id)
    add_index(:group_order_article_results, :group_order_result_id)
  end

  def self.down
    drop_table :group_order_results
    drop_table :order_article_results
    drop_table :group_order_article_results
  end
end
