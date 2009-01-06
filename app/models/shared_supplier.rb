class SharedSupplier < ActiveRecord::Base
  # used for gettext
  untranslate_all
  
  # connect to database from sharedLists-Application
  SharedSupplier.establish_connection(FoodSoft::get_shared_lists_config)
  # set correct table_name in external DB
  set_table_name :suppliers
  
  
  has_one :supplier
  has_many :shared_articles, :foreign_key => :supplier_id
  
  # save the lists as an array
  serialize :lists
  
end
