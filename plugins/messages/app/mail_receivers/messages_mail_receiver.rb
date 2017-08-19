class MessagesMailReceiver

  def self.regexp
    /(?<message_id>\d+)\.(?<user_id>\d+)\.(?<hash>\w+)/
  end

  def received(match, data)
    original_message = Message.find_by_id(match[:message_id])
    user = User.find_by_id(match[:user_id])

    raise "Message could not be found" if original_message.nil?
    raise "User could not be found" if user.nil?

    hash = original_message.mail_hash_for_user user
    raise "Hash does not match expectations" unless hash.casecmp(match[:hash]) == 0

    mail = Mail.new data

    mail_part = nil
    if mail.multipart?
      for part in mail.parts
        mail_part = part if MIME::Type.simplified(part.content_type) == "text/plain"
      end
    else
      mail_part = mail
    end

    body = mail_part.body.decoded
    unless mail_part.content_type_parameters.nil?
      body = body.force_encoding mail_part.content_type_parameters[:charset]
    end

    message = user.send_messages.new body: body,
      group: original_message.group,
      private: original_message.private,
      received_email: received_email,
      subject: mail.subject.gsub("[#{FoodsoftConfig[:name]}] ", "")
    if original_message.reply_to
      message.reply_to_message = original_message.reply_to_message
    else
      message.reply_to_message = original_message
    end
    message.add_recipients original_message.recipients
    message.add_recipients [original_message.sender]

    message.save!
    Resque.enqueue(MessageNotifier, FoodsoftConfig.scope, "message_deliver", message.id)
  end

end
