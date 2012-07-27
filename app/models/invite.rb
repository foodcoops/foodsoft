require 'digest/sha1'

# Invites are created by foodcoop users to invite a new user into the foodcoop and their order group.
class Invite < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of :user
  validates_presence_of :group
  validates_presence_of :token
  validates_presence_of :expires_at
  validate :email_not_already_registered, :on => :create

      
 protected
  
  # Before validation, set token and expires_at.
  def before_validation
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
    self.expires_at = Time.now.advance(:days => 7)
  end

  # Sends an email to the invited user.
  def after_create
    Mailer.invite(self).deliver
  end

 private

  # Custom validation: check that email does not already belong to a registered user.
  def email_not_already_registered
    unless User.find_by_email(self.email).nil?
      errors.add(:email, 'ist bereits in Verwendung. Person ist schon Mitglied der Foodcoop.')
    end
  end

end

