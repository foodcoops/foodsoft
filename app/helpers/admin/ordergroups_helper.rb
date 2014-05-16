module Admin::OrdergroupsHelper
  def price_markup_collection
    list = FoodsoftConfig[:price_markup_list] or return
    list.keys.map {|id| [show_price_markup(id, format: :full), id] }
  end
end
