ActiveSupport.on_load(:after_initialize) do
  # We simulate the shared database by pointing to our own database.
  #   This allows running tests without additional database setup.
  #   But take care when designing tests using the shared database.
  SharedSupplier.establish_connection Rails.env.to_sym
  SharedArticle.establish_connection Rails.env.to_sym
  # hack for different structure of shared database
  SharedArticle.class_eval do
    self.table_name = 'shared_articles'

    belongs_to :supplier, class_name: 'SharedSupplier'
    alias_attribute :updated_on, :updated_at
    def order_number=(num)
      self.number = num
    end

    def order_number
      self.number
    end

    def category
      ArticleCategory.where(id: article_category_id).first
    end

    def article_category_id
      nil
    end
  end

  SharedSupplier.class_eval do
    self.table_name = 'shared_suppliers'

    def find_article_by_number(num)
      self.shared_articles.find_by_number(num)
    end
  end
end
