class SharedSupplier < ActiveRecord::Base

  # connect to database from sharedLists-Application
  SharedSupplier.establish_connection(FoodsoftConfig[:shared_lists])
  # set correct table_name in external DB
  self.table_name = 'suppliers'

  has_many :suppliers
  has_many :shared_articles, :foreign_key => :supplier_id

  def find_article_by_number(order_number)
    #note inconsistent naming, order_number = number in supplier db
    cached_articles_by_key(['number'])[cache_key([order_number])]
  end

  def find_article_by_name_origin_manufacture(name, origin, manufacturer)
    cached_articles_by_key(['name', 'origin', 'manufacturer'])[cache_key([name, origin, manufacturer])]
  end

  def find_article_by_name_manufacture(name, manufacturer)
    cached_articles_by_key(['name', 'manufacturer'])[cache_key([name, manufacturer])]
  end

  def cache_key(keys)
    keys.join('::')
  end

  def cached_articles
    # puts "cached #{id}" if @cached_articles
    # puts "shared supplier not cached #{id}" unless @cached_articles
    @cached_articles ||= shared_articles.all
  end

  def cached_articles_by_key(keys)
    @cached_articles_by_key ||= {}
    @cached_articles_by_key[keys.join('::')] ||= cached_articles.map do |a|
      vals = keys.map {|k| a[k]}
      [cache_key(vals), a]
    end.to_h
  end

  # These set of attributes are used to autofill attributes of new supplier,
  # when created by import from shared supplier feature.
  def autofill_attributes
    whitelist = %w(name address phone fax email url delivery_days note)
    attributes.select { |k,_v| whitelist.include?(k) }
  end

  # return list of synchronisation methods available for this supplier
  def shared_sync_methods
    methods = []
    methods += %w(all_available all_unavailable)  if shared_articles.count < (FoodsoftConfig[:shared_supplier_article_limit] || 200)
    methods += %w(import) # perhaps, in the future: if shared_articles.count > 20
    methods
  end
end

