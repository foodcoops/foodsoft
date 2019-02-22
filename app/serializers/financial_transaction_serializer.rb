class FinancialTransactionSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id, :user_id, :user_name, :amount, :note, :created_at

  def user_name
    show_user object.user
  end

  def amount
    object.amount.to_f
  end
end
