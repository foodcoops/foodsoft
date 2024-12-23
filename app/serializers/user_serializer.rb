class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :locale, :ordergroup_name, :ordergroup_id
end
