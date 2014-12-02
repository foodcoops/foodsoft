class MessagesMailer < Mailer
  # Sends an email copy of the given internal foodsoft message.
  def foodsoft_message(message, recipient)
    set_foodcoop_scope
    @message = message

    mail subject: "[#{FoodsoftConfig[:name]}] " + message.subject,
         to: recipient.email,
         from: "#{show_user(message.sender)} <#{message.sender.email}>"
  end
end
