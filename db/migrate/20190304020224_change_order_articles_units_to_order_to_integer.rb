class ChangeOrderArticlesUnitsToOrderToInteger < ActiveRecord::Migration
  def change
    # floor all values (otherwise they are rounded)
    OrderArticle.all.each do |oa|
      if (oa.units_to_order % 1 > 0)
        oa.units_to_order = oa.units_to_order.floor
        oa.save
      end
    end
    change_column :order_articles, :units_to_order,
                  :integer, limit: 4, default: 0, null: false
  end
end
