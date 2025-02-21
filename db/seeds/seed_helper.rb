# only works properly for open orders, at the moment
def seed_group_orders
  Order.all.each do |order|
    noas = order.order_articles.count
    Ordergroup.all.each do |og|
      # 20% of the order-ordergroup combinations don't order
      next if rand(10) < 2

      # order 3..12 times a random article
      go = og.group_orders.create!(order: order, updated_by_user_id: 1)
      rand(3..12).times do
        goa = go.group_order_articles.find_or_create_by!(order_article: order.order_articles.offset(rand(noas)).first)
        unit_quantity = goa.order_article.article_version.unit_quantity
        goa.update_quantities rand([4, (unit_quantity * 2) + 2].max), rand(unit_quantity)
      end
    end
    # update totals
    order.order_articles.map(&:update_results!)
    order.group_orders.map(&:update_price!)
  end
end

def seed_order(options = {})
  options[:article_ids] ||= (options[:supplier] || Supplier.find(options[:supplier_id])).articles.map(&:id)
  options[:created_by_user_id] ||= 1
  options[:updated_by_user_id] ||= 1
  Order.create! options
end
