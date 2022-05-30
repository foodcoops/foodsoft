class MirkoSerializer < ActiveModel::Serializer
  attributes :id
  # has_many :group_order_articles, serializer: MirkoSubSerializer
  attributes :enddate
  attributes :pickupdate
  attributes :order_state
  attributes :suppliername
  attributes :article_details
  attributes :transport

  def article_details
    object.group_order_articles.map do |goa|
      { id: goa.id,
        name: goa.order_article.article.name,
        unit: goa.order_article.article.unit,
        price: goa.order_article.article.price,
        ordered: goa.quantity, received: goa.result }
    end
  end

  def suppliername
    object.order.name
  end

  def enddate
    object.order.ends
  end

  def pickupdate
    object.order.pickup
  end

  def order_state
    object.order.state
  end
end
