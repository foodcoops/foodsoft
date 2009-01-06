require 'digest/sha1'

# Invites are created by foodcoop users to invite a new user into the foodcoop and their order group.
# 
# Attributes:
# * token - the authentication token for this invite
# * group - the group the new user is to be made a member of
# * user - the inviting user
# * expires_at - the time this invite expires
# * email - the recipient's email address
class Invite < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'ist keine gültige Email-Adresse'
  validates_presence_of :user
  validates_presence_of :group
  validates_presence_of :token
  validates_presence_of :expires_at
  
  attr_accessible :email, :user, :group
  
  # messages
  ERR_EMAIL_IN_USE = 'ist bereits in Verwendung'
  
 protected
  
  # Before validation, set token and expires_at.
  def before_validation
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
    self.expires_at = Time.now.advance(:days => 2)
  end

  # Sends an email to the invited user.
  def after_create
    Mailer.deliver_invite(self)
  end

 private

  # Custom validation: check that email does not already belong to a registered user.
  def validate_on_create
    errors.add(:email, ERR_EMAIL_IN_USE) unless User.find_by_email(self.email).nil?
  end

end
