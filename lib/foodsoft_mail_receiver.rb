require 'mail'
require 'midi-smtp-server'

class FoodsoftMailReceiver < MidiSmtpServer::Smtpd

  @@registered_classes = Set.new

  def self.register(klass)
    @@registered_classes.add klass
  end

  def self.received(recipient, data)
    find_handler(recipient).call(data)
  end

  def start
    super
    @handlers = []
  end

  private

  def on_rcpt_to_event(ctx, rcpt_to)
    recipient = rcpt_to.gsub(/^\s*<\s*(.*)\s*>\s*$/, '\1')
    @handlers << self.class.find_handler(recipient)
    rcpt_to
  rescue => error
    logger.info("Can not accept mail for '#{rcpt_to}': #{error}")
    raise MidiSmtpServer::Smtpd550Exception
  end

  def on_message_data_event(ctx)
    begin
      @handlers.each do |handler|
        handler.call(ctx[:message][:data])
      end
    rescue => error
      ExceptionNotifier.notify_exception(error, data: ctx)
      raise error
    ensure
      @handlers.clear
    end
  end

  def self.find_handler(recipient)
    m = /(?<foodcoop>[^@\.]+)\.(?<address>[^@]+)(@(?<hostname>[^@]+))?/.match recipient
    raise "recipient is missing or has an invalid format" if m.nil?
    raise "Foodcoop '#{m[:foodcoop]}' could not be found" unless FoodsoftConfig.allowed_foodcoop? m[:foodcoop]
    FoodsoftConfig.select_multifoodcoop m[:foodcoop]

    @@registered_classes.each do |klass|
      if match = klass.regexp.match(m[:address])
        handler = klass.new match
        return lambda { |data| handler.received(data) }
      end
    end

    raise "invalid format for recipient"
  end

end
