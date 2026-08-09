class AlterGroupOrderArticlesIncreasePrecision < ActiveRecord::Migration[7.2]
  def up
    change_table :group_order_articles do |t|
      t.change :result, :decimal, precision: 12, scale: 6
      t.change :result_computed, :decimal, precision: 12, scale: 6
    end
  end

  def down
    change_table :group_order_articles do |t|
      t.change :result, :decimal, precision: 8, scale: 3
      t.change :result_computed, :decimal, precision: 8, scale: 3
    end
  end
end
