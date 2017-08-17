class MessageNotifier < UserNotifier
  @queue = :foodsoft_notifier

  def self.message_deliver(args)
    message_id = args.first
    message = Message.find(message_id)

    message.recipients.each do |recipient|
      if recipient.receive_email?
        begin
          MessagesMailer.foodsoft_message(recipient, message).deliver
        rescue
          Rails.logger.warn "Deliver failed for user \##{recipient.id}: #{recipient.email}"
        end
      end
    end

    message.update_attribute(:email_state, 1)
  end
end
