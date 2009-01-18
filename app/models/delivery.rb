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
  has_one :invoice
  has_many :stock_changes

  named_scope :recent, :order => 'created_at DESC', :limit => 10

  validates_presence_of :supplier_id

  def stock_change_attributes=(stock_change_attributes)
    for attributes in stock_change_attributes
      stock_changes.build(attributes) unless attributes[:quantity] == 0.0 or attributes[:quantity].blank?
    end
  end
  
end
