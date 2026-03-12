class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :locale, :ordergroup_name, :ordergroup_id

  def ordergroup_id
    object.ordergroup ? object.ordergroup.id : nil
  end
end
