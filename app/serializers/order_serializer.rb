class OrderSerializer < ActiveModel::Serializer
  attributes :id, :name, :starts, :ends, :boxfill, :is_open, :is_boxfill

  def is_open
    object.open?
  end

  def is_boxfill
    !!object.boxfill?
  end
end
