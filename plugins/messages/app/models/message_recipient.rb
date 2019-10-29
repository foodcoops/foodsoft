class MessageRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  enum email_state: [:pending, :sent, :skipped]
end
