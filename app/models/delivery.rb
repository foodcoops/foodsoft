# == Schema Information
# Schema version: 20090102171850
#
# Table name: deliveries
#
#  id           :integer(4)      not null, primary key
#  supplier_id  :integer(4)
#  delivered_on :date
#  created_at   :datetime
#

class Delivery < ActiveRecord::Base

  belongs_to :supplier

  validates_presence_of :supplier_id
end
