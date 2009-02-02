# == Schema Information
# Schema version: 20090119155930
#
# Table name: order_comments
#
#  id         :integer         not null, primary key
#  order_id   :integer
#  user_id    :integer
#  text       :text
#  created_at :datetime
#

class OrderComment < ActiveRecord::Base

  belongs_to :order
  belongs_to :user

  validates_presence_of :order_id, :user_id, :text
end
