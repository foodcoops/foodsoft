require 'digest/sha1'

# Invites are created by foodcoop users to invite a new user into the foodcoop and their order group.
class Invite < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_presence_of :user
  validates_presence_of :group
  validates_presence_of :token
  validates_presence_of :expires_at
  validate :email_not_already_registered, :on => :create

  before_validation :set_token_and_expires_at
      
 protected
  
  # Before validation, set token and expires_at.
  def set_token_and_expires_at
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
    self.expires_at = Time.now.advance(:days => 7)
  end

 private

  # Custom validation: check that email does not already belong to a registered user.
  def email_not_already_registered
    unless User.find_by_email(self.email).nil?
      errors.add(:email, I18n.t('invites.errors.already_member'))
    end
  end

end

