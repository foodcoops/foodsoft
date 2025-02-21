require 'net/http'

class Supplier < ApplicationRecord
  include MarkAsDeletedWithName
  include CustomFields

  has_many :articles, lambda {
                        merge(Article.not_in_stock.with_latest_versions_and_categories.order('article_categories.name, article_versions.name'))
                      }
  has_many :stock_articles, lambda {
                              merge(StockArticle.with_latest_versions_and_categories.order('article_categories.name, article_versions.name'))
                            }
  has_many :orders
  has_many :deliveries
  has_many :invoices
  belongs_to :supplier_category

  validates :name, presence: true, length: { in: 4..30 }
  validates :phone, presence: true, length: { in: 8..25 }
  validates :address, presence: true, length: { in: 8..50 }
  validates :iban, format: { with: /\A[A-Z]{2}[0-9]{2}[0-9A-Z]{,30}\z/, allow_blank: true }
  validates :iban, uniqueness: { case_sensitive: false, allow_blank: true }
  validates :order_howto, :note, length: { maximum: 250 }
  validate :uniqueness_of_name
  validates :shared_sync_method, presence: true, unless: -> { supplier_remote_source.blank? }
  validates :shared_sync_method, absence: true, if: -> { supplier_remote_source.blank? }
  validates :supplier_remote_source, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  enum shared_sync_method: { all_available: 'all_available', all_unavailable: 'all_unavailable', import: 'import' }

  scope :undeleted, -> { where(deleted_at: nil) }
  scope :having_articles, -> { where(id: Article.undeleted.select(:supplier_id).distinct) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[articles stock_articles orders]
  end

  # Synchronise articles with spreadsheet.
  #
  # @param file [File] Spreadsheet file to parse
  # @param options [Hash] Options passed to {FoodsoftFile#parse} except when listed here.
  # @option options [Boolean] :outlist_absent Set to +true+ to remove articles not in spreadsheet.
  # @option options [Boolean] :convert_units Omit or set to +true+ to keep current units, recomputing unit quantity and price.
  def sync_from_file(file, options = {})
    data = FoodsoftFile.parse(file, options)
    data.each do |new_attrs|
      new_article = foodsoft_file_attrs_to_article(new_attrs.dup)
      new_attrs[:price] = new_attrs[:price].to_d / new_article.convert_quantity(1, new_article.price_unit, new_article.supplier_order_unit)
    end
    parse_import_data({ articles: data }, options) + [data]
  end

  def read_from_remote(search_params = {})
    url = URI(supplier_remote_source)
    url.query = URI.encode_www_form(search_params) unless search_params.nil?
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = url.scheme == 'https'
    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    JSON.parse(response.body, symbolize_names: true)
  end

  def sync_from_remote(options = {})
    data = read_from_remote(options[:search_params])
    parse_import_data(data, options) + [data]
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    transaction do
      super
      update_column :iban, nil
      articles.each(&:mark_as_deleted)
    end
  end

  # @return [Boolean] Whether there are articles that would use tolerance
  def has_tolerance?
    articles.with_latest_versions_and_categories.any? { |article| article.latest_article_version.uses_tolerance? }
  end

  # TODO: Maybe use the `nilify_blanks` gem instead of the following two methods? (see https://github.com/foodcoopsat/foodsoft_hackathon/issues/93):
  def supplier_remote_source=(value)
    if value.blank?
      self[:supplier_remote_source] = nil
    else
      super
    end
  end

  def shared_sync_method=(value)
    if value.blank?
      self[:shared_sync_method] = nil
    else
      super
    end
  end

  protected

  # Make sure, the name is uniq, add usefull message if uniq group is already deleted
  def uniqueness_of_name
    supplier = Supplier.where(name: name)
    supplier = supplier.where.not(id: id) unless new_record?
    return unless supplier.exists?

    message = supplier.first.deleted? ? :taken_with_deleted : :taken
    errors.add :name, message
  end

  def parse_import_data(data, options = {})
    all_order_numbers = []
    updated_article_pairs = []
    outlisted_articles = []
    new_articles = []

    data[:articles].each do |new_attrs|
      article = articles.includes(:latest_article_version).undeleted.where(article_versions: { order_number: new_attrs[:order_number] }).first
      new_article = foodsoft_file_attrs_to_article(new_attrs)

      if new_attrs[:availability]
        if article.nil?
          new_articles << new_article
        else
          unequal_attributes = article.unequal_attributes(new_article, options.slice(:convert_units))
          unless unequal_attributes.empty?
            article.latest_article_version.article_unit_ratios.target.clear unless unequal_attributes[:article_unit_ratios_attributes].nil?
            article.latest_article_version.attributes = unequal_attributes
            duped_ratios = article.latest_article_version.article_unit_ratios.map(&:dup)
            article.latest_article_version.article_unit_ratios.target.clear
            article.latest_article_version.article_unit_ratios.target.push(*duped_ratios)
            updated_article_pairs << [article, unequal_attributes]
          end
        end
      elsif article.present?
        outlisted_articles << article
      end
      all_order_numbers << article.order_number if article
    end
    outlisted_articles += articles.includes(:latest_article_version).undeleted.where.not(article_versions: { order_number: all_order_numbers + [nil] }) if options[:outlist_absent]
    [updated_article_pairs, outlisted_articles, new_articles]
  end

  def foodsoft_file_attrs_to_article(foodsoft_file_attrs)
    foodsoft_file_attrs = foodsoft_file_attrs.dup
    foodsoft_file_attrs[:article_category] = ArticleCategory.find_match(foodsoft_file_attrs[:article_category])
    foodsoft_file_attrs[:tax] ||= FoodsoftConfig[:tax_default]
    foodsoft_file_attrs[:article_unit_ratios] = foodsoft_file_attrs[:article_unit_ratios].map do |ratio_hash|
      ArticleUnitRatio.new(ratio_hash)
    end
    new_article = articles.build
    new_article_version = new_article.article_versions.build(foodsoft_file_attrs)
    new_article.article_versions << new_article_version
    new_article.latest_article_version = new_article_version

    new_article
  end
end
