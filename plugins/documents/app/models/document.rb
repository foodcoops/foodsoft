class Document < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'

  validates_presence_of :data
end
