class Page < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'updated_by'

  acts_as_versioned :version_column => :lock_version, :limit => 20
  self.non_versioned_columns += ['permalink', 'created_at', 'title']
  acts_as_tree :order => "title"

  attr_accessor :old_title # Save title to create redirect page when editing title

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :title

  before_validation :set_permalink, :on => :create
  before_validation :update_permalink, :on => :update
  after_update :create_redirect

  scope :non_redirected, :conditions => {:redirect => nil}
  scope :no_parent, :conditions => {:parent_id => nil}

  def self.permalink(title)
    title.gsub(/[\/\.,;@\s]/, "_").gsub(/[\"\']/, "")
  end

  def homepage?
    permalink == "Home"
  end

  def set_permalink
    unless title.blank?
      self.permalink = Page.count == 0 ? "Home" : Page.permalink(title)
    end
  end

  protected

  def update_permalink
    if changed.include?("title")
      set_permalink
      self.old_title = changes["title"].first # Save title for creating redirect
    end
  end

  def create_redirect
    unless old_title.blank?
      Page.create :redirect => id,
        :title => old_title,
        :body => "Weiterleitung auf [[#{title}]]..",
        :permalink => Page.permalink(old_title),
        :updated_by => updated_by
    end
  end
end

# == Schema Information
#
# Table name: pages
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  body         :text
#  permalink    :string(255)
#  lock_version :integer(4)      default(0)
#  updated_by   :integer(4)
#  redirect     :integer(4)
#  parent_id    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

