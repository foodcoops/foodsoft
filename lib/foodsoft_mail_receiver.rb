require 'mail'
require 'midi-smtp-server'

class FoodsoftMailReceiver < MidiSmtpServer::Smtpd
  @registered_classes = Set.new

  def self.register(klass)
    @registered_classes.add klass
  end

  def self.received(recipient, data)
    find_handler(recipient).call(data)
  end

  def start
    super
    @handlers = []
  end

  def self.find_handler(recipient)
    m = /(?<foodcoop>[^@.]+)\.(?<address>[^@]+)(?:@(?<hostname>[^@]+))?/.match recipient
    raise 'recipient is missing or has an invalid format' if m.nil?
    raise "Foodcoop '#{m[:foodcoop]}' could not be found" unless FoodsoftConfig.allowed_foodcoop? m[:foodcoop]

    FoodsoftConfig.select_multifoodcoop m[:foodcoop]

    @registered_classes.each do |klass|
      if match = klass.regexp.match(m[:address])
        handler = klass.new match
        return ->(data) { handler.received(data) }
      end
    end

    raise 'invalid format for recipient'
  end

  private_class_method :find_handler

  private

  def on_rcpt_to_event(_ctx, rcpt_to)
    recipient = rcpt_to.gsub(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    @handlers << self.class.find_handler(recipient)
    rcpt_to
  rescue StandardError => e
    logger.info("Can not accept mail for '#{rcpt_to}': #{e}")
    raise MidiSmtpServer::Smtpd550Exception
  end

  def on_message_data_event(ctx)
    @handlers.each do |handler|
      handler.call(ctx[:message][:data])
    end
  rescue StandardError => e
    ExceptionNotifier.notify_exception(e, data: ctx)
    raise e
  ensure
    @handlers.clear
  end
end
