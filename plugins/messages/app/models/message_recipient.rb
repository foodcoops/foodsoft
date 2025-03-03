class MessageRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  enum email_state: %i[pending sent skipped failed]
end
