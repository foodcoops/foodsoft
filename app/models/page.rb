# == Schema Information
# Schema version: 20090325175756
#
# Table name: pages
#
#  id           :integer         not null, primary key
#  title        :string(255)
#  body         :text
#  permalink    :string(255)
#  lock_version :integer         default(0)
#  updated_by   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Page < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'updated_by'

  acts_as_versioned :version_column => :lock_version
  self.non_versioned_columns += ['permalink', 'created_at']

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink

  before_validation_on_create :set_permalink

  def self.permalink(title)
    Wikitext::Parser.new.parse "[[#{title}]]"
  end

  def set_permalink
    unless self.permalink.blank?
      self.permalink = Page.count == 0 ? "Home" : Page.permalink(title)
    end
  end
end
