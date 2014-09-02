# http://stackoverflow.com/questions/8774227
# http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite
class ActiveRecord::Base
    mattr_accessor :shared_connection
    @@shared_connection = nil
       
    def self.connection
      @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
    end
end
# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

ActiveSupport.on_load(:after_initialize) do
  # We simulate the shared database by pointing to our own database.
  #   This allows running tests without additional database setup.
  #   But take care when designing tests using the shared database.
  SharedSupplier.establish_connection Rails.env
  SharedArticle.establish_connection Rails.env
  # hack for different structure of shared database
  SharedArticle.class_eval do
    alias_attribute :number, :order_number
    alias_attribute :updated_on, :updated_at
    def category
      ArticleCategory.find(article_category_id).name
    end
    def self.find_by_number(n)
      find_by_order_number(n)
    end
  end
end
