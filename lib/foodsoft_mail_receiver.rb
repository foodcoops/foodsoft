require 'mail'
require 'midi-smtp-server'

class FoodsoftMailReceiver < MidiSmtpServer::Smtpd

  @@registered_classes = Set.new

  def self.register(klass)
    @@registered_classes.add klass
  end

  def self.received(recipient, data)
    m = /(?<foodcoop>[^@\.]+)\.(?<address>[^@]+)(@(?<hostname>[^@]+))?/.match recipient
    raise "recipient is missing or has an invalid format" if m.nil?
    raise "Foodcoop '#{m[:foodcoop]}' could not be found" unless FoodsoftConfig.foodcoops.include? m[:foodcoop]
    FoodsoftConfig.select_multifoodcoop m[:foodcoop]

    @@registered_classes.each do |klass|
      klass_m = klass.regexp.match(m[:address])
      return klass.new(klass_m).received(data) if klass_m
    end

    raise "invalid format for recipient"
  end

  def start
    super
  end

  private

  def on_message_data_event(ctx)
    puts ctx[:envelope][:to]
    ctx[:envelope][:to].each do |to|
      begin
        m = /<(?<recipient>[^<>]+)>/.match(to)
        raise "invalid format for RCPT TO" if m.nil?
        FoodsoftMailReceiver.received(m[:recipient], ctx[:message][:data])
      rescue => error
        Rails.logger.warn "Can't deliver mail to #{to}: #{error.message}"
      end
    end
  end

end
