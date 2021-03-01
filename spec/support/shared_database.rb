ActiveSupport.on_load(:after_initialize) do
  # We simulate the shared database by pointing to our own database.
  #   This allows running tests without additional database setup.
  #   But take care when designing tests using the shared database.
  SharedSupplier.establish_connection Rails.env.to_sym
  SharedArticle.establish_connection Rails.env.to_sym
  # hack for different structure of shared database
  SharedArticle.class_eval do
    belongs_to :supplier, class_name: 'SharedSupplier'
    alias_attribute :number, :order_number
    alias_attribute :updated_on, :updated_at
    def category
      ArticleCategory.where(id: article_category_id).first
    end

    def self.find_by_number(n)
      find_by_order_number(n)
    end
  end
end
