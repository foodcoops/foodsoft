# Article category
class ArticleCategory < ApplicationRecord
  # @!attribute name
  #   @return [String] Title of the category.
  # @!attrubute description
  #   @return [String] Description (currently unused)

  # @!attribute articles
  #   @return [Array<Article>] Articles with this category.
  has_many :articles
  # @!attribute order_articles
  #   @return [Array<OrderArticle>] Order articles with this category.
  has_many :order_articles, through: :articles
  # @!attribute orders
  #   @return [Array<Order>] Orders with articles in this category.
  has_many :orders, through: :order_articles

  normalize_attributes :name, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2 }

  before_destroy :check_for_associated_articles

  def self.ransackable_attributes(auth_object = nil)
    %w(id name)
  end

  def self.ransackable_associations(auth_object = nil)
    %w(articles order_articles orders)
  end

  # Find a category that matches a category name; may return nil.
  # TODO more intelligence like remembering earlier associations (global and/or per-supplier)
  def self.find_match(category)
    return if category.blank? || category.length < 3

    c = nil
    ## exact match - not needed, will be returned by next query as well
    # c ||= ArticleCategory.where(name: category).first
    # case-insensitive substring match (take the closest match = shortest)
    c = ArticleCategory.where('name LIKE ?', "%#{category}%") unless c && c.any?
    # case-insensitive phrase present in category description
    c = ArticleCategory.where('description LIKE ?', "%#{category}%").select { |s| s.description.match /(^|,)\s*#{category}\s*(,|$)/i } unless c && c.any?
    # return closest match if there are multiple
    c = c.sort_by { |s| s.name.length }.first if c.respond_to? :sort_by
    c
  end

  protected

  # Deny deleting the category when there are associated articles.
  def check_for_associated_articles
    raise I18n.t('activerecord.errors.has_many_left', collection: Article.model_name.human) if articles.undeleted.exists?
  end
end
