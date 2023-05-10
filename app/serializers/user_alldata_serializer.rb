class UserAlldataSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :locale, :phone, :ordergroupid
  # conditional!
  #   https://github.com/rails-api/active_model_serializers/blob/0-10-stable/docs/general/serializers.md#attribute
  attribute :deleted_at, unless: -> { object.deleted_at.nil? }

  def ordergroupid
    object.ordergroup ? object.ordergroup.id : nil
  end
end
