class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :locale
end
