# == Schema Information
# Schema version: 20090102171850
#
# Table name: article_categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     default(""), not null
#  description :string(255)
#

class ArticleCategory < ActiveRecord::Base
  has_many :articles
	
  validates_length_of :name, :in => 2..20
  validates_uniqueness_of :name

end
