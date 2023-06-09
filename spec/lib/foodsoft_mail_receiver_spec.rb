require_relative '../spec_helper'

describe FoodsoftMailReceiver do
  before :all do
    @server = FoodsoftMailReceiver.new(ports: '2525', hosts: '127.0.0.1', max_processings: 4, logger_severity: 5)
    @server.start
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

  it 'does not accept empty addresses' do
    FoodsoftMailReceiver.received('', 'body')
  rescue StandardError => e
    expect(e.to_s).to include 'missing'
  end

  it 'does not accept invalid addresses' do
    FoodsoftMailReceiver.received('invalid', 'body')
  rescue StandardError => e
    expect(e.to_s).to include 'has an invalid format'
  end

  it 'does not accept invalid scope in address' do
    FoodsoftMailReceiver.received('invalid.invalid', 'body')
  rescue StandardError => e
    expect(e.to_s).to include 'could not be found'
  end

  it 'does not accept address without handler' do
    address = "#{FoodsoftConfig[:default_scope]}.invalid"
    FoodsoftMailReceiver.received(address, 'body')
  rescue StandardError => e
    expect(e.to_s).to include 'invalid format for recipient'
  end

  it 'does not accept invalid addresses via SMTP' do
    expect do
      Net::SMTP.start(@server.hosts.first, @server.ports.first) do |smtp|
        smtp.send_message 'body', 'from@example.com', 'invalid'
      end
    end.to raise_error(Net::SMTPFatalError)
  end

  it 'does not accept invalid addresses via SMTP' do
    expect do
      Net::SMTP.start(@server.hosts.first, @server.ports.first) do |smtp|
        smtp.send_message 'body', 'from@example.com', 'invalid'
      end
    end.to raise_error(Net::SMTPFatalError)
  end
end
