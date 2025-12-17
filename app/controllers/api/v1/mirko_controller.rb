class Api::V1::MirkoController < Api::V1::BaseController
  before_action -> { doorkeeper_authorize! 'orders:read' }

  def index
    time_now = Time.now
    base_scope = GroupOrder
      .includes(group_order_articles: { order_article: :article },
                order: :supplier)
      .references(:orders)
      .where(ordergroup_id: current_user.ordergroup.id)
      .limit(200)
    gos = base_scope.where(
      orders: {
        state: "open",
        pickup: nil, # z.B. Leergut Rückgabe
        ends: time_now.weeks_ago(1)..time_now.next_year
      }
    ).or(
      base_scope.where(
        orders: {
          state: "open",
          supplier_id: nil, # Lager
          ends: time_now.weeks_ago(1)..time_now.next_year
        }
      )  
    ).or(
      base_scope.where(
        orders: {
          state: %w[finished received closed],
          pickup: time_now.weeks_ago(5)..time_now.weeks_ago(-1)
        }
      )
    )
    render json: gos, each_serializer: MirkoSerializer
  end
end
