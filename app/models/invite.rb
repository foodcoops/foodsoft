require 'digest/sha1'

# Invites are created by foodcoop users to invite a new user into the foodcoop and their order group.
class Invite < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :user, presence: true
  validates :group, presence: true
  validates :token, presence: true
  validates :expires_at, presence: true
  validate :email_not_already_registered, on: :create

  before_validation :set_token_and_expires_at

  protected

  # Before validation, set token and expires_at.
  def set_token_and_expires_at
    self.token = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
    self.expires_at = Time.now.advance(days: 7)
  end

  private

  # Custom validation: check that email does not already belong to a registered user.
  def email_not_already_registered
    return if User.find_by_email(email).nil?

    errors.add(:email, I18n.t('invites.errors.already_member'))
  end
end
