module Admin::OrdergroupsHelper
  def price_markup_collection
    list = FoodsoftConfig[:price_markup_list] or return
    list.keys.map {|id| [price_markup_title(id), id] }
  end

  def price_markup_title(id)
    if list = FoodsoftConfig[:price_markup_list]
      "#{list[id]['name'] or id} (#{number_to_percentage list[id]['markup']})"
    else
      number_to_percentage list[id]['markup']
    end
  end
end
