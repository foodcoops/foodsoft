class Page < ActiveRecord::Base

  validates_presence_of :title, :body

  before_save :set_permalink

  def set_permalink
    if self.permalink.blank? #FIXME: or title.changed?
      self.permalink = Page.count == 0 ? "home" : "#{title.downcase.strip.gsub(/ |\.|@/, '-')}"
    end
  end
end
