class OrderComment < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates_presence_of :order_id, :user_id, :text
  validates_length_of :text, :minimum => 3
end
