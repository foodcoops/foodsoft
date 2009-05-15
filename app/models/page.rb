class Page < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'updated_by'

  acts_as_versioned
  self.non_versioned_columns += ['permalink', 'created_at']

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink

  before_validation_on_create :set_permalink

  def set_permalink
    if self.permalink.blank?
      self.permalink = Page.count == 0 ? "home" : "#{title.downcase.strip.gsub(/ |\.|@/, '-')}"
    end
  end
end
