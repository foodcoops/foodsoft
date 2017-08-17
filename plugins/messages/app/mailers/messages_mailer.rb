class MessagesMailer < Mailer
  # Sends an email copy of the given internal foodsoft message.
  def foodsoft_message(recipient, message)
    @message = message

    reply_email_domain = FoodsoftConfig[:reply_email_domain]
    if reply_email_domain
      hash = message.mail_hash_for_user recipient
      reply_to = "#{I18n.t('layouts.foodsoft')} <#{FoodsoftConfig.scope}.#{message.id}.#{recipient.id}.#{hash}@#{reply_email_domain}>"
    end

    mail to: recipient,
         from: message.sender,
         reply_to: reply_to,
         subject: message.subject
  end
end
