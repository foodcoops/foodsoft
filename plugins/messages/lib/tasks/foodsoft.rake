require "mail"
require "mini-smtp-server"

class ReplyEmailSmtpServer < MiniSmtpServer

  def new_message_event(message_hash)
    m = /<(?<recipient>[^<>]+)>/.match(message_hash[:to])
    raise "invalid format for RCPT TO" if m.nil?
    hande_mail(m[:recipient], message_hash[:data])
  rescue => error
    rake_say error.message
  end

end

namespace :foodsoft do
  desc "Parse incoming email on stdin (options: RECIPIENT=f.1.2.a1b2c3d3e5)"
  task :parse_reply_email => :environment do
    hande_mail(ENV['RECIPIENT'], STDIN.read)
  end

  desc "Start STMP server for incoming email (options: PORT=25, HOST=0.0.0.0)"
  task :reply_email_smtp_server => :environment do
    port = ENV['PORT'].to_i
    host = ENV['HOST']
    rake_say "Started SMTP server for incomming email on port #{port}."
    server = ReplyEmailSmtpServer.new(port, host)
    server.start
    server.join
  end
end

def hande_mail(recipient, received_email)
  m = /(?<foodcoop>[^@]*)\.(?<message_id>\d+)\.(?<user_id>\d+)\.(?<hash>\w+)(@(?<hostname>.*))?/.match(recipient)

  raise "RECIPIENT is missing or has an invalid format" if m.nil?
  raise "Foodcoop '#{m[:foodcoop]}' could not be found" unless FoodsoftConfig.foodcoops.include? m[:foodcoop]

  FoodsoftConfig.select_multifoodcoop m[:foodcoop]
  original_message = Message.find_by_id(m[:message_id])
  user = User.find_by_id(m[:user_id])

  raise "Message could not be found" if original_message.nil?
  raise "User could not be found" if user.nil?

  hash = original_message.mail_hash_for_user user
  raise "Hash does not match expectations" unless hash.casecmp(m[:hash]) == 0

  mail = Mail.new received_email

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
    subject: mail.subject
  if original_message.reply_to
    message.reply_to_message = original_message.reply_to_message
  else
    message.reply_to_message = original_message
  end
  message.add_recipients original_message.recipients
  message.add_recipients [original_message.sender]

  message.save!
  Resque.enqueue(MessageNotifier, FoodsoftConfig.scope, "message_deliver", message.id)
  rake_say "Handled reply email from #{user.display}."
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
