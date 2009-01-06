class SharedArticle < ActiveRecord::Base
  
  # gettext-option
  untranslate_all
  
  # connect to database from sharedLists-Application
  SharedArticle.establish_connection(FoodSoft::get_shared_lists_config)
  # set correct table_name in external DB
  set_table_name :articles
  
  belongs_to :shared_supplier, :foreign_key => :supplier_id
end
