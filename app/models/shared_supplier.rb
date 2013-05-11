class SharedSupplier < ActiveRecord::Base
  
  # connect to database from sharedLists-Application
  SharedSupplier.establish_connection(FoodsoftConfig[:shared_lists])
  # set correct table_name in external DB
  self.table_name = 'suppliers'

  has_one :supplier
  # note that there is at least one production database with multiple suppliers
  # assigned to the same shared_supplier (beisswat)
  
  has_many :shared_articles, :foreign_key => :supplier_id
  
end

