class Api::V1::PickupController < Api::V1::BaseController
 
  def index   
   # get group orders for ordergroup with ordergroup_id
    ordergroup_id = params.fetch(:ordergroup_id, nil) || 
      (current_user.ordergroup ? current_user.ordergroup.id : nil)
    base_scope = GroupOrder
      .includes(group_order_articles: { order_article: :article },
                order: [:supplier, :comments])
      .references(:orders)
      .where(ordergroup_id: ordergroup_id)
      .limit(200)
    group_orders = base_scope.where(
      orders: {
        state: "open",
        pickup: nil, # z.B. Leergut Rückgabe
        ends: last_week
      }
    ).or(
      base_scope.where(
        orders: {
          state: "open",
          supplier_id: nil, # Lager
          ends: last_week
        }
      )  
    ).or(
      base_scope.where(
        orders: {
          state: %w[finished received closed],
          pickup: last_weeks
        }
      )
    )
    render json: 
    {
      group_orders: group_orders.map { |go|
        {
          id: go.id, 
          ends: go.order.ends,
          pickup: go.order.pickup,
          state: go.order.state,
          order_id: go.order.id,
          name: go.order.name,
          supplier_note: go.order.supplier ? go.order.supplier.note : ""  ,
          articles: go.group_order_articles.map { |goa|
            { id: goa.id,
              name: goa.order_article.article.name,
              unit: goa.order_article.article.unit,
              price: goa.order_article.article.price,
              deposit: goa.order_article.article.deposit,
              ordered: goa.quantity,
              tolerance: goa.tolerance, 
              received: goa.result,   
            }
          }
        }
      }         
    }
  end

  def show
    result = params.require(:id) 
    if result == "users" 
      # get all active users and their ordergroup (if member of an ordergroup)  
      ordergroup_subquery = Membership
        .joins(:group)
        .where(groups: { type: "Ordergroup" })
        .select("memberships.user_id, groups.*")
      users = User.undeleted
        .joins(
          "LEFT JOIN (#{ordergroup_subquery.to_sql}) AS ordergroups
          ON ordergroups.user_id = users.id"
        )     
        .select(
          "users.*,
          ordergroups.id   AS ordergroup_id,
          ordergroups.name AS ordergroup_name"
        )
      render json:  
      {
        users: users.map { |user|
          { 
            id: user.id, 
            name: user.name,
            email: user.email, 
            locale: user.locale, 
            ordergroup_id: user[:ordergroup_id] || nil,
            ordergroup_name:  user[:ordergroup_name] || nil,
          }
        }
      }
    elsif result == "orders"
      # get orders for all ordergroups
      order_ids = params.fetch(:ids, "").split(",").map(&:to_i)
      if order_ids.any?
        orders = Order.where(id: order_ids).includes(
          :supplier,
          :comments, 
          order_articles:  { group_order_articles: { group_order: :ordergroup }}
        ) 
        render json:
        { 
          orders: orders.map { |order|
            { 
              id: order.id,
              name: order.name,
              state: order.state,
              ends: order.ends,
              pickup: order.pickup,
              supplier_note: order.supplier ? order.supplier.note : ""  ,
              articles: order.order_articles.map { |oa|
                oa.group_order_articles.any? ? { 
                  id: oa.id,
                  name: oa.article.name,
                  unit: oa.article.unit,
                  price: oa.article.price,
                  deposit: oa.article.deposit,
                  grouporders: oa.group_order_articles.map { |goa|
                    { 
                      id: goa.id,
                      ordergroup_name: (goa.group_order.ordergroup ? goa.group_order.ordergroup.name : "none"),
                      ordered: goa.quantity,
                      tolerance: goa.tolerance, 
                      received: goa.result, 
                    }
                  }
                } : nil 
              }.compact, # remove nil elements
              comments: order.comments,
            }
          }
        }
      else 
        # no order ids specified: get overview for order selection   
        orders = Order.where(
            state: %w[finished received closed],
            pickup: last_weeks
        ).includes(:supplier)
        render json:
        {
          orders: orders.map { |order|
            { # only overview for order selection, no article details
              id: order.id,
              name: order.name,
              state: order.state,
              ends: order.ends,
              pickup: order.pickup,
              supplier_note: order.supplier ? order.supplier.note : ""  
            }
          }
        }
      end
    end
  end

  def update
    # update GroupOrderArticle attributes like received and create order comments
    order_id = params.require(:id)
    comment = params.fetch(:comment, "")
    if comment && order_id
      Order.transaction do
        order = Order.find(order_id)
        order.comments.create(user: current_user, text:comment)
      end
    end
    GroupOrderArticle.transaction do
      params.fetch(:updates, {}).each do |article_id, property_updates| 
        goa = GroupOrderArticle.find(article_id)
        property_updates.each do |property, value|
          goa.update_attribute(property, value) # allows updates for closed orders, skips validation
          if property == "result" && params.fetch(:update_result_sum, true)
            total = GroupOrderArticle.where(order_article_id: goa.order_article_id).sum(:result)
            goa.order_article.update!(units_received: total)  
          end
        end
      end
    end
  end

  private

  def time_now
    if Rails.env.development?
      Time.new(2025, 12, 17)
    else
      Time.current
    end
  end

  def last_week
    time_now.weeks_ago(1)..time_now.next_year
  end

  def last_weeks
    time_now.weeks_ago(params.fetch(:weeks, 5))..time_now.weeks_since(1)
  end

end
