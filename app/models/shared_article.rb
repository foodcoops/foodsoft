class SharedArticle < ActiveRecord::Base

  # connect to database from sharedLists-Application
  SharedArticle.establish_connection(FoodsoftConfig[:shared_lists])
  # set correct table_name in external DB
  self.table_name = 'articles'

  belongs_to :shared_supplier, :foreign_key => :supplier_id

  def build_new_article
    # The supplier might be overwritten subsequently.
    # TODO: Confirm that this works.
    shared_supplier.supplier.articles.build(
        :name => name,
        :unit => unit,
        :note => note,
        :manufacturer => manufacturer,
        :origin => origin,
        :price => price,
        :tax => tax,
        :deposit => deposit,
        :unit_quantity => unit_quantity,
        :order_number => number,
        # convert to db-compatible-string
        :shared_updated_on => updated_on.to_formatted_s(:db)
    )
  end
end
