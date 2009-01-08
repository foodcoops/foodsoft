# == Schema Information
# Schema version: 20090102171850
#
# Table name: articles
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)     not null
#  supplier_id    :integer(4)      not null
#  number         :string(255)
#  note           :string(255)
#  manufacturer   :string(255)
#  origin         :string(255)
#  unit           :string(255)
#  price          :decimal(8, 2)   default(0.0), not null
#  tax            :decimal(3, 1)   default(7.0), not null
#  deposit        :decimal(8, 2)   default(0.0), not null
#  unit_quantity  :decimal(4, 1)   default(1.0), not null
#  scale_quantity :decimal(4, 2)
#  scale_price    :decimal(8, 2)
#  created_on     :datetime
#  updated_on     :datetime
#  list           :string(255)
#

class SharedArticle < ActiveRecord::Base
  
  # connect to database from sharedLists-Application
  SharedArticle.establish_connection(APP_CONFIG[:shared_lists])
  # set correct table_name in external DB
  set_table_name :articles
  
  belongs_to :shared_supplier, :foreign_key => :supplier_id
end
