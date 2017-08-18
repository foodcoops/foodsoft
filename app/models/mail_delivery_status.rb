class MailDeliveryStatus < ActiveRecord::Base
  self.table_name = 'mail_delivery_status'

  belongs_to :user, foreign_key: 'email', primary_key: 'email'
end
