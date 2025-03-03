class DeliverMessageJob < ApplicationJob
  def perform(message)
    @errors = Array.new
    message.message_recipients.each do |message_recipient|
      # Skip the action if email_state is :sent
      next if message_recipient.email_state == 'sent'

      recipient = message_recipient.user
      if recipient.receive_email?
        begin
          Mailer.deliver_now_with_user_locale recipient do
            MessagesMailer.foodsoft_message(recipient, message)
          end
          message_recipient.update_attribute :email_state, :sent
        rescue => e
          # Handle the exception (e.g., log the error, set email_state to :failed, etc.)
          # Rails.logger.error (["Failed to deliver message #{message.id} to recipient #{recipient.id}:"]+e.backtrace).join("\n")
          @errors << e
          message_recipient.update_attribute :email_state, :failed
        end
      else
        message_recipient.update_attribute :email_state, :skipped
      end
    end
    unless @errors.empty?
      raise StandardError.new (["At least deliery to one recipient for message: #{message.id} failed"]+@errors).join("\n")
    end
  end
end
