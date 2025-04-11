class BounceMailReceiver
  def self.regexp
    /bounce\+(?<local>.*)=(?<domain>[^=]+)/
  end

  def initialize(match)
    @address = "#{match[:local]}@#{match[:domain]}"
  end

  def received(data)
    mail = Mail.new data
    subject = mail.subject || 'Unknown bounce error'
    MailDeliveryStatus.create email: @address,
                              message: subject,
                              attachment_mime: 'message/rfc822',
                              attachment_data: data
  end
end
