# Article category
class ArticleCategory < ActiveRecord::Base

  # @!attribute name
  #   @return [String] Title of the category.
  # @!attrubute description
  #   @return [String] Description (currently unused)

  # @!attribute articles
  #   @return [Array<Article>] Articles with this category.
  has_many :articles

  normalize_attributes :name, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :in => 2..20 }

  before_destroy :check_for_associated_articles

  protected

  # Deny deleting the category when there are associated articles.
  def check_for_associated_articles
    raise I18n.t('activerecord.errors.has_many_left', collection: Article.model_name.human) if articles.undeleted.exists?
  end

end

