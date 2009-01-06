class ArticleCategory < ActiveRecord::Base
  has_many :articles
	
  validates_length_of :name, :in => 2..20
  validates_uniqueness_of :name

end
