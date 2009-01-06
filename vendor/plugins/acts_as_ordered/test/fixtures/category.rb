class Category < ActiveRecord::Base
  has_many :projects
end
