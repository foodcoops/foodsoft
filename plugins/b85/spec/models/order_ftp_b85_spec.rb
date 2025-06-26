require 'spec_helper'

describe Order do
  describe 'sending to supplier with FTP B85' do
    let(:user) { create(:user) }
    let(:supplier) do
      create(:supplier, article_count: 1, remote_order_url: 'ftp://user:pass@example.com/path',
                        customer_number: '12345', remote_order_method: 'ftp_b85')
    end
    let(:order) { create(:order, supplier: supplier) }
    let(:ftp_mock) { instance_double(Net::FTP) }
    let(:current_time) { Time.current }

    before do
      allow(Time).to receive(:now).and_return(current_time)
      allow(Net::FTP).to receive(:open).and_yield(ftp_mock)
      allow(ftp_mock).to receive(:login)
      allow(ftp_mock).to receive(:putbinaryfile)

      ActionMailer::Base.deliveries.clear
      Supplier.add_remote_order_method_value(:ftp_b85, 'ftp_b85')
    end

    it 'uploads order via FTP in B85 format and does not send email' do
      order.send_to_supplier!(user)

      expect(Net::FTP).to have_received(:open).with('example.com')
      expect(ftp_mock).to have_received(:login).with('user', 'pass')
      expect(ftp_mock).to have_received(:putbinaryfile) do |_, remote_filename|
        expect(remote_filename).to match(/BE\d{6}\.\d{3}$/)
      end
      expect(ActionMailer::Base.deliveries.count).to eq 0
      expect(order.remote_ordered_at.to_i).to eq(current_time.to_i)
    end
  end
end
