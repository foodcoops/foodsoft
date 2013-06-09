class SharedSupplier < ActiveRecord::Base
  
  # connect to database from sharedLists-Application
  SharedSupplier.establish_connection(FoodsoftConfig[:shared_lists])
  # set correct table_name in external DB
  self.table_name = 'suppliers'

  has_one :supplier
  has_many :shared_articles, :foreign_key => :supplier_id

  # These set of attributes are used to autofill attributes of new supplier,
  # when created by import from shared supplier feature.
  def autofill_attributes
    whitelist = %w(name address phone fax email url delivery_days note)
    attributes.select { |k,_v| whitelist.include?(k) }
  end
end

