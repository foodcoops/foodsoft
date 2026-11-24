module Pickup
  # The group orders of an ordergroup that are waiting to be picked up.
  module Orders
    extend ActiveSupport::Concern

    # Orders further back than this are not listed: the pickup apps are for the
    # last few weeks, not an archive.
    WINDOW_WEEKS = 8
    # Hard cap of records a client gets in one call, so an old foodcoop with
    # thousands of orders does not serialise all of them.
    LIMIT = 200

    private

    # Group orders of +ordergroup+ that an app should show for pickup: the
    # order ended at most WINDOW_WEEKS ago, and either
    #  * is a stock order (no supplier -- picked up right after ordering),
    #  * has a pickup date in the recent past or the coming week, or
    #  * is still open without a pickup date (deposit return and the like).
    #
    # Orders whose pickup lies further back have been settled in the meantime;
    # the web PickupsController#index stays authoritative for those.
    def pickup_group_orders(ordergroup)
      GroupOrder
        .where(ordergroup_id: ordergroup.id)
        .joins(:order)
        .includes(group_order_articles: { order_article: :article_version }, order: :supplier)
        .where('orders.ends > ?', Time.zone.now - WINDOW_WEEKS.weeks)
        .where(
          'orders.supplier_id IS NULL ' \
          'OR orders.pickup BETWEEN ? AND ? ' \
          'OR (orders.state = ? AND orders.pickup IS NULL)',
          Time.zone.now - WINDOW_WEEKS.weeks, Time.zone.now + 1.week, 'open'
        )
        .order('orders.ends DESC').limit(LIMIT)
    end
  end
end
