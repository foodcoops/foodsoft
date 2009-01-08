# == Schema Information
# Schema version: 20090102171850
#
# Table name: suppliers
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     not null
#  address       :string(255)     not null
#  phone         :string(255)     not null
#  phone2        :string(255)
#  fax           :string(255)
#  email         :string(255)
#  url           :string(255)
#  delivery_days :string(255)
#  note          :string(255)
#  created_on    :datetime
#  updated_on    :datetime
#  lists         :string(255)
#

class SharedSupplier < ActiveRecord::Base
  
  # connect to database from sharedLists-Application
  SharedSupplier.establish_connection(APP_CONFIG[:shared_lists])
  # set correct table_name in external DB
  set_table_name :suppliers
  
  
  has_one :supplier
  has_many :shared_articles, :foreign_key => :supplier_id
  
  # save the lists as an array
  serialize :lists
  
end
