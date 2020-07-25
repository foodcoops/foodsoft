require_relative '../spec_helper'

describe FoodsoftMailReceiver do

  before :all do
    @server = FoodsoftMailReceiver.new 2525, '127.0.0.1', 4, logger_severity: 5
    @server.start
  end

  it 'does not accept empty addresses' do
    begin
      FoodsoftMailReceiver.received('', 'body')
    rescue => error
      expect(error.to_s).to include 'missing'
    end
  end

  it 'does not accept invalid addresses' do
    begin
      FoodsoftMailReceiver.received('invalid', 'body')
    rescue => error
      expect(error.to_s).to include 'has an invalid format'
    end
  end

  it 'does not accept invalid scope in address' do
    begin
      FoodsoftMailReceiver.received('invalid.invalid', 'body')
    rescue => error
      expect(error.to_s).to include 'could not be found'
    end
  end

  it 'does not accept address without handler' do
    begin
      address = "#{FoodsoftConfig[:default_scope]}.invalid"
      FoodsoftMailReceiver.received(address, 'body')
    rescue => error
      expect(error.to_s).to include 'invalid format for recipient'
    end
  end

  it 'does not accept invalid addresses via SMTP' do
    expect {
      Net::SMTP.start(@server.hosts.first, @server.ports.first) do |smtp|
        smtp.send_message 'body', 'from@example.com', 'invalid'
      end
    }.to raise_error(Net::SMTPFatalError)
  end

  it 'does not accept invalid addresses via SMTP' do
    expect {
      Net::SMTP.start(@server.hosts.first, @server.ports.first) do |smtp|
        smtp.send_message 'body', 'from@example.com', 'invalid'
      end
    }.to raise_error(Net::SMTPFatalError)
  end

  # TODO: Reanable this test.
  # It raised "Mysql2::Error: Lock wait timeout exceeded" at time of writing.
  # it 'accepts bounce mails via SMTP' do
  #   MailDeliveryStatus.delete_all
  #
  #   Net::SMTP.start(@server.host, @server.port) do |smtp|
  #     address = "#{FoodsoftConfig[:default_scope]}.bounce+user=example.com"
  #     smtp.send_message 'report', 'from@example.com', address
  #   end
  #
  #   mds = MailDeliveryStatus.last
  #   expect(mds.email).to eq 'user@example.com'
  #   expect(mds.attachment_mime).to eq 'message/rfc822'
  #   expect(mds.attachment_data).to include 'report'
  # end

  after :all do
    @server.shutdown
  end

end
