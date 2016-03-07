class MessagesMailer < Mailer
  # Sends an email copy of the given internal foodsoft message.
  def foodsoft_message(message, recipient)
    set_foodcoop_scope
    @message = message

    reply_email_domain = FoodsoftConfig[:reply_email_domain]
    if reply_email_domain
      hash = message.mail_hash_for_user recipient
      reply_to = "#{I18n.t('layouts.foodsoft')} <#{FoodsoftConfig.scope}.#{message.id}.#{recipient.id}.#{hash}@#{reply_email_domain}>"
    else
      reply_to = "#{show_user(message.sender)} <#{message.sender.email}>"
    end

    mail subject: "[#{FoodsoftConfig[:name]}] " + message.subject,
         to: recipient.email,
         from: "#{show_user(message.sender)} via #{I18n.t('layouts.foodsoft')} <#{FoodsoftConfig[:email_sender]}>",
         reply_to: reply_to
  end
end
