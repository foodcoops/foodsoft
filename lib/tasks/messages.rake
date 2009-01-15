desc "Deliver messages as emails"
task :send_emails => :environment do
  Message.send_emails
end
