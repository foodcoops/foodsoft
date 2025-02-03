require 'email_reply_trimmer'

class MessagesMailReceiver
  def self.regexp
    /(?<message_id>\d+)\.(?<user_id>\d+)\.(?<hash>\w+)/
  end

  def initialize(match)
    @message = Message.find_by_id(match[:message_id])
    @user = User.find_by_id(match[:user_id])

    raise 'Message could not be found' if @message.nil?
    raise 'User could not be found' if @user.nil?

    hash = @message.mail_hash_for_user(@user)
    raise 'Hash does not match expectations' unless hash.casecmp(match[:hash]) == 0
  end

  def received(data)
    mail = Mail.new data

    mail_part = get_mail_part(mail)
    raise 'No valid content could be found' if mail_part.nil?

    body = mail_part.body.decoded
    body = body.force_encoding mail_part.content_type_parameters[:charset] unless mail_part.content_type_parameters.nil?

    body = Nokogiri::HTML(body).text if MIME::Type.simplified(mail_part.content_type) == 'text/html'

    body.encode!(Encoding.default_internal)
    body = EmailReplyTrimmer.trim(body)
    raise BlankBodyException if body.empty?

    ActiveRecord::Base.transaction do
      message = @user.send_messages.new body: body,
                                        group: @message.group,
                                        private: @message.private,
                                        received_email: data
      message.reply_to_message = if @message.reply_to
                                   @message.reply_to_message
                                 else
                                   @message
                                 end
      message.subject = if mail.subject
                          mail.subject.gsub("[#{FoodsoftConfig[:name]}] ", '')
                        else
                          I18n.t('messages.model.reply_subject', subject: message.reply_to_message.subject)
                        end
      message.add_recipients [@message.sender_id]

      message.save!
      DeliverMessageJob.perform_later(message)
    end
  end

  private

  def get_mail_part(mail)
    return mail unless mail.multipart?

    mail_part = nil
    for part in mail.parts
      part = get_mail_part(part)
      content_type = MIME::Type.simplified(part.content_type)
      mail_part = part if content_type == 'text/plain' || (!mail_part && content_type == 'text/html')
    end
    mail_part
  end

  class BlankBodyException < MidiSmtpServer::SmtpdException
    def initialize(msg = nil)
      super(msg, 541, 'The recipient address rejected your message because of a blank plain body')
    end
  end
end
