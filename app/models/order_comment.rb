class OrderComment < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :order_id, :user_id, :text, presence: true
  validates :text, length: { minimum: 3 }
end
