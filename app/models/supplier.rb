class Supplier < ActiveRecord::Base
  has_many :articles, :dependent => :destroy
  has_many :orders
  attr_accessible :name, :address, :phone, :phone2, :fax, :email, :url, :contact_person, :customer_number, :delivery_days, :order_howto, :note, :shared_supplier_id, :min_order_quantity
	
  validates_length_of :name, :in => 4..30
  validates_uniqueness_of :name

  validates_length_of :phone, :in => 8..20
  validates_length_of :address, :in => 8..50
  
  # for the sharedLists-App
  belongs_to :shared_supplier
  
  # Returns all articles for this supplier that are available and have a valid price, grouped by article category and ordered by name.
  def getArticlesAvailableForOrdering
    articles = Article.find(:all, :conditions => ['supplier_id = ? AND availability = ?', self.id, true], :order => 'article_categories.name, articles.name', :include => :article_category)
    articles.select {|article| article.gross_price}
  end
  
  # sync all articles with the external database
  # returns an array with articles(and prices), which should be updated (to use in a form)
  # also returns an array with outlisted_articles, which should be deleted
  def sync_all
    updated_articles = Array.new
    outlisted_articles = Array.new
    for article in articles.find(:all, :order => "article_categories.name", :include => :article_category)
      # try to find the associated shared_article
      shared_article = article.shared_article
      if shared_article
        # article will be updated
        
        # skip if shared_article has not been changed
        unequal_attributes = article.shared_article_changed?
        unless unequal_attributes.blank?
          # update objekt but don't save it
          
          # try to convert different units
          new_price, new_unit_quantity = article.convert_units
          if new_price and new_unit_quantity
            article.net_price = new_price
            article.unit_quantity = new_unit_quantity
          else
            article.net_price = shared_article.price
            article.unit_quantity = shared_article.unit_quantity
            article.unit = shared_article.unit
          end
          # update other attributes
          article.attributes = {
            :name => shared_article.name,
            :manufacturer => shared_article.manufacturer,
            :origin => shared_article.origin,
            :shared_updated_on => shared_article.updated_on,
            :tax => shared_article.tax,
            :deposit => shared_article.deposit,
            :note => shared_article.note
          }
          updated_articles << [article, unequal_attributes]
        end
      else
        # article isn't in external database anymore
        outlisted_articles << article
      end
    end
    return [updated_articles, outlisted_articles]
  end
end
