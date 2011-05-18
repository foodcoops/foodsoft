class ArticleCategory < ActiveRecord::Base
  has_many :articles

  validates :name, :presence => true, :uniqueness => true, :length => { :in => 2..20 }

end

# == Schema Information
#
# Table name: article_categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     default(""), not null
#  description :string(255)
#

