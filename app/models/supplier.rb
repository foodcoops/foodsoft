# encoding: utf-8
class Supplier < ActiveRecord::Base
  include MarkAsDeletedWithName

  has_many :articles, -> { where(:type => nil).includes(:article_category).order('article_categories.name', 'articles.name') }
  has_many :stock_articles, -> { includes(:article_category).order('article_categories.name', 'articles.name') }
  has_many :orders
  has_many :deliveries
  has_many :invoices
  belongs_to :shared_supplier  # for the sharedLists-App

  include ActiveModel::MassAssignmentSecurity
  attr_accessible :name, :address, :phone, :phone2, :fax, :email, :url, :contact_person, :customer_number,
                  :delivery_days, :order_howto, :note, :shared_supplier_id, :min_order_quantity, :shared_sync_method

  validates :name, :presence => true, :length => { :in => 4..30 }
  validates :phone, :presence => true, :length => { :in => 8..25 }
  validates :address, :presence => true, :length => { :in => 8..50 }
  validates_length_of :order_howto, :note, maximum: 250
  validate :valid_shared_sync_method
  validate :uniqueness_of_name

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :having_articles, -> { where(id: Article.undeleted.select(:supplier_id).distinct) }

  # sync all articles with the external database
  # returns an array with articles(and prices), which should be updated (to use in a form)
  # also returns an array with outlisted_articles, which should be deleted
  # also returns an array with new articles, which should be added (depending on shared_sync_method)
  def sync_all
    updated_article_pairs, outlisted_articles, new_articles = [], [], []
    for article in articles.undeleted
      # try to find the associated shared_article
      shared_article = article.shared_article(self)

      if shared_article # article will be updated
        unequal_attributes = article.shared_article_changed?(self)
        unless unequal_attributes.blank? # skip if shared_article has not been changed
          article.attributes = unequal_attributes
          updated_article_pairs << [article, unequal_attributes]
        end
      # Articles with no order number can be used to put non-shared articles
      # in a shared supplier, with sync keeping them.
      elsif not article.order_number.blank?
        # article isn't in external database anymore
        outlisted_articles << article
      end
    end
    # Find any new articles, unless the import is manual
    unless shared_sync_method == 'import'
      for shared_article in shared_supplier.shared_articles
        unless articles.undeleted.find_by_order_number(shared_article.number)
          new_articles << shared_article.build_new_article(self)
        end
      end
    end
    return [updated_article_pairs, outlisted_articles, new_articles]
  end

  # Synchronise articles with spreadsheet.
  #
  # @param file [File] Spreadsheet file to parse
  # @param options [Hash] Options passed to {FoodsoftFile#parse} except when listed here.
  # @option options [Boolean] :outlist_absent Set to +true+ to remove articles not in spreadsheet.
  # @option options [Boolean] :convert_units Omit or set to +true+ to keep current units, recomputing unit quantity and price.
  def sync_from_file(file, options={})
    all_order_numbers = []
    updated_article_pairs, outlisted_articles, new_articles = [], [], []
    FoodsoftFile::parse file, options do |status, new_attrs, line|
      article = articles.undeleted.where(order_number: new_attrs[:order_number]).first
      new_attrs[:article_category] = ArticleCategory.find_match(new_attrs[:article_category])
      new_attrs[:tax] ||= FoodsoftConfig[:tax_default]
      new_article = articles.build(new_attrs)

      if status.nil?
        if article.nil?
          new_articles << new_article
        else
          unequal_attributes = article.unequal_attributes(new_article, options.slice(:convert_units))
          unless unequal_attributes.empty?
            article.attributes = unequal_attributes
            updated_article_pairs << [article, unequal_attributes]
          end
        end
      elsif status == :outlisted && article.present?
        outlisted_articles << article

      # stop when there is a parsing error
      elsif status.is_a? String
        # @todo move I18n key to model
        raise I18n.t('articles.model.error_parse', :msg => status, :line => line.to_s)
      end

      all_order_numbers << article.order_number if article
    end
    if options[:outlist_absent]
      outlisted_articles += articles.undeleted.where.not(id: all_order_numbers+[nil])
    end
    return [updated_article_pairs, outlisted_articles, new_articles]
  end

  # default value
  def shared_sync_method
    return unless shared_supplier
    self[:shared_sync_method] || 'import'
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    transaction do
      super
      articles.each(&:mark_as_deleted)
    end
  end

  protected

  # make sure the shared_sync_method is allowed for the shared supplier
  def valid_shared_sync_method
    if shared_supplier && !shared_supplier.shared_sync_methods.include?(shared_sync_method)
      errors.add :name, :included
    end
  end

  # Make sure, the name is uniq, add usefull message if uniq group is already deleted
  def uniqueness_of_name
    supplier = Supplier.where(name: name)
    supplier = supplier.where.not(id: self.id) unless new_record?
    if supplier.exists?
      message = supplier.first.deleted? ? :taken_with_deleted : :taken
      errors.add :name, message
    end
  end
end
