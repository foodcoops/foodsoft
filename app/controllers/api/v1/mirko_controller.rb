class Api::V1::MirkoController < Api::V1::BaseController
  before_action -> { doorkeeper_authorize! 'orders:read' }

  def index
    time_now = Time.now
    gos = GroupOrder
          .includes(group_order_articles: { order_article: :article },
                    order: :supplier)
          .references(:orders)
          .where(ordergroup_id: current_user.ordergroup.id)
          .limit(200)
          .where(orders: {
                   ends: (time_now.weeks_ago(1)..time_now.next_year), state: "open", pickup: nil
                 })
          .or(
            GroupOrder
              .includes(group_order_articles: { order_article: :article },
                        order: :supplier)
              .references(:orders)
              .where(ordergroup_id: current_user.ordergroup.id)
              .limit(200)
              .where(orders: {
                       pickup: ((time_now.weeks_ago(5)..(time_now.weeks_ago(-1)))), state: %w[finished received closed]
                     })
          )
    render json: gos, each_serializer: MirkoSerializer
  end
end
