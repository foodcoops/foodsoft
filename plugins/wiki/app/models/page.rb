class Page < ApplicationRecord
  include ActsAsTree

  belongs_to :user, :foreign_key => 'updated_by'

  acts_as_versioned version_column: :lock_version
  self.non_versioned_columns += %w(permalink created_at title)

  acts_as_tree :order => "title"

  attr_accessor :old_title # Save title to create redirect page when editing title

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :title

  before_validation :set_permalink, :on => :create
  before_validation :update_permalink, :on => :update
  after_update :create_redirect

  scope :non_redirected, -> { where(:redirect => nil) }
  scope :no_parent, -> { where(:parent_id => nil) }

  def self.permalink(title)
    title.gsub(/[\/\.,;@\s]/, "_").gsub(/[\"\']/, "")
  end

  def homepage?
    permalink == "Home"
  end

  def self.dashboard
    where(permalink: "Dashboard").first
  end

  def self.public_front_page
    where(permalink: "Public_frontpage").first
  end

  def self.welcome_mail
    where(permalink: "Welcome_mail").first
  end

  def set_permalink
    unless title.blank?
      self.permalink = Page.count == 0 ? "Home" : Page.permalink(title)
    end
  end

  def diff
    current = versions.latest
    old = versions.where(["page_id = ? and lock_version < ?", current.page_id, current.lock_version]).order('lock_version DESC').first

    if old
      o = ''
      Diffy::Diff.new(old.body, current.body).each do |line|
        case line
        when /^\+/ then o += "#{line.chomp}<br />" unless line.chomp == "+"
        when /^-/ then o += "#{line.chomp}<br />" unless line.chomp == "-"
        end
      end
      o
    else
      current.body
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
        :body => I18n.t('model.page.redirect', :title => title),
        :permalink => Page.permalink(old_title),
        :updated_by => updated_by
    end
  end
end
