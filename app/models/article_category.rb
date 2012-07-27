class ArticleCategory < ActiveRecord::Base
  has_many :articles

  validates :name, :presence => true, :uniqueness => true, :length => { :in => 2..20 }

end

