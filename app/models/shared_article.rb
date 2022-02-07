class SharedArticle < ApplicationRecord
  # connect to database from sharedLists-Application
  SharedArticle.establish_connection(FoodsoftConfig[:shared_lists])
  # set correct table_name in external DB
  self.table_name = 'articles'

  belongs_to :shared_supplier, :foreign_key => :supplier_id

  def build_new_article(supplier)
    supplier.articles.build(
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
      :article_category => ArticleCategory.find_match(category),
      # convert to db-compatible-string
      :shared_updated_on => updated_on.to_formatted_s(:db)
    )
  end
end
