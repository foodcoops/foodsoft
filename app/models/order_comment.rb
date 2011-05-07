class OrderComment < ActiveRecord::Base

  belongs_to :order
  belongs_to :user

  validates_presence_of :order_id, :user_id, :text
end

# == Schema Information
#
# Table name: order_comments
#
#  id         :integer(4)      not null, primary key
#  order_id   :integer(4)
#  user_id    :integer(4)
#  text       :text
#  created_at :datetime
#

