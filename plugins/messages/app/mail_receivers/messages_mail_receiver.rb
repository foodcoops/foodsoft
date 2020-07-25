require "email_reply_trimmer"

class MessagesMailReceiver

  def self.regexp
    /(?<message_id>\d+)\.(?<user_id>\d+)\.(?<hash>\w+)/
  end

  def initialize(match)
    @message = Message.find_by_id(match[:message_id])
    @user = User.find_by_id(match[:user_id])

    raise "Message could not be found" if @message.nil?
    raise "User could not be found" if @user.nil?

    hash = @message.mail_hash_for_user(@user)
    raise "Hash does not match expectations" unless hash.casecmp(match[:hash]) == 0
  end

  def received(data)
    mail = Mail.new data

    mail_part = get_mail_part(mail)
    raise "No valid content could be found" if mail_part.nil?

    body = mail_part.body.decoded
    unless mail_part.content_type_parameters.nil?
      body = body.force_encoding mail_part.content_type_parameters[:charset]
    end

    if MIME::Type.simplified(mail_part.content_type) == "text/html"
      body = Nokogiri::HTML(body).text
    end

    body.encode!(Encoding::default_internal)
    body = EmailReplyTrimmer.trim(body)

    if body.empty?
      raise MidiSmtpServer::SmtpdException(nil, 541, "The recipient address rejected your message because of a blank plain body")
    end

    message = @user.send_messages.new body: body,
      group: @message.group,
      private: @message.private,
      received_email: data
    if @message.reply_to
      message.reply_to_message = @message.reply_to_message
    else
      message.reply_to_message = @message
    end
    if mail.subject
      message.subject = mail.subject.gsub("[#{FoodsoftConfig[:name]}] ", "")
    else
      message.subject = I18n.t('messages.model.reply_subject', subject: message.reply_to_message.subject)
    end
    message.add_recipients [@message.sender_id]

    message.save!
    Resque.enqueue(MessageNotifier, FoodsoftConfig.scope, "message_deliver", message.id)
  end

  private

  def get_mail_part(mail)
    return mail unless mail.multipart?

    mail_part = nil
    for part in mail.parts
      part = get_mail_part(part)
      content_type = MIME::Type.simplified(part.content_type)
      if content_type == "text/plain" || !mail_part && content_type == "text/html"
        mail_part = part
      end
    end
    mail_part
  end

end
