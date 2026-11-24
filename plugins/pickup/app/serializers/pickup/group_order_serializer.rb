module Pickup
  # A group order with the articles it contains, as a pickup app lists them for
  # a single ordergroup.
  class GroupOrderSerializer < ActiveModel::Serializer
    attributes :id, :order_id, :ordergroup_id, :name, :state, :ends, :pickup, :note

    has_many :group_order_articles, key: :articles, serializer: Pickup::GroupOrderArticleSerializer

    def ordergroup_id
      object.ordergroup_id
    end

    def state
      object.order.state
    end

    def ends
      object.order.ends
    end

    def pickup
      object.order.pickup
    end

    # Note for the people picking up, the same one the web listing shows. Not
    # the supplier's note -- order_id is in the payload for that.
    def note
      object.order.note
    end

    # Name of the supplier, or of the stock for an order without one -- the
    # same as the web listing shows.
    def name
      object.order.name
    end
  end
end
