class ArticleCategory < ActiveRecord::Base
  has_many :articles

  validates :name, :presence => true, :uniqueness => true, :length => { :in => 2..20 }

  before_destroy :check_for_associated_articles

  protected

  def check_for_associated_articles
    raise I18n.t('activerecord.errors.has_many_left', collection: Article.model_name.human) if articles.undeleted.exists?
  end

end

