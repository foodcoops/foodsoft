class SharedArticle < ActiveRecord::Base
  
  # connect to database from sharedLists-Application
  SharedArticle.establish_connection(APP_CONFIG[:shared_lists])
  # set correct table_name in external DB
  set_table_name :articles
  
  belongs_to :shared_supplier, :foreign_key => :supplier_id
end
