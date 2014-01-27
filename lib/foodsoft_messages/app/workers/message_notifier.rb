class MessageNotifier < UserNotifier
  @queue = :foodsoft_notifier

  def self.message_deliver(args)
    message_id = args.first
    Message.find(message_id).deliver
  end
end
