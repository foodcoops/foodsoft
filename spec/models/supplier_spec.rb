require_relative '../spec_helper'

describe Supplier do
  let(:supplier) { create(:supplier) }

  context 'syncs from file' do
    it 'imports and updates articles' do
      article1 = create(:article, supplier: supplier, order_number: 177_813, unit: '250 g', price: 0.1)
      article2 = create(:article, supplier: supplier, order_number: 12_345)
      supplier.articles = [article1, article2]
      options = { filename: 'foodsoft_file_01.csv' }
      options[:outlist_absent] = true
      updated_article_pairs, outlisted_articles, new_articles = supplier.sync_from_file(
        Rails.root.join('spec/fixtures/foodsoft_file_01.csv'), options
      )
      expect(new_articles.length).to be > 0
      expect(updated_article_pairs.first[1][:name]).to eq 'Tomaten'
      expect(outlisted_articles.first).to eq article2
    end
  end

  describe '#read_from_remote' do
    context 'with HTTP/S protocol' do
      let(:sample_data) { { articles: [{ name: 'Test Article', price: 1.99 }] } }
      let(:http_double) { instance_double(Net::HTTP) }
      let(:response_double) { instance_double(Net::HTTPResponse) }

      before do
        allow(supplier).to receive(:supplier_remote_source).and_return('https://example.org/data.json')
        allow(Net::HTTP).to receive(:new).and_return(http_double)
        allow(http_double).to receive(:use_ssl=)
        allow(http_double).to receive(:request).and_return(response_double)
        allow(response_double).to receive(:body).and_return(sample_data.to_json)
      end

      it 'fetches data from HTTP/S source' do
        result = supplier.read_from_remote
        expect(result).to eq(sample_data)
      end

      it 'handles search parameters' do
        result = supplier.read_from_remote(query: 'test')
        expect(http_double).to have_received(:request) do |request|
          expect(request.path).to include('query=test')
        end
        expect(result).to eq(sample_data)
      end
    end

    context 'with FTP protocol' do
      let(:sample_data) do
        { 'data1.json' => { articles: [{ name: 'Article 1', price: 1.99 }] },
          'data2.json' => { articles: [{ name: 'Article 2', price: 2.99 }] } }
      end
      let(:ftp_double) { instance_double(Net::FTP) }

      before do
        allow(Net::FTP).to receive(:new).and_return(ftp_double)
        allow(ftp_double).to receive(:connect)
        allow(ftp_double).to receive(:login)
        allow(ftp_double).to receive(:passive=)
        allow(ftp_double).to receive(:chdir)
        allow(ftp_double).to receive(:close)
        allow(ftp_double).to receive(:nlst).and_return(%w[data1.json data2.json other.txt])
        allow(ftp_double).to receive(:getbinaryfile) do |remote_file_name, local_file|
          File.write(local_file, sample_data[remote_file_name].to_json) if sample_data.key?(remote_file_name)
        end
      end

      it 'fetches data from FTP source' do
        allow(supplier).to receive(:supplier_remote_source).and_return('ftp://example.com/path/data1.json')

        result = supplier.read_from_remote
        expect(result).to eq(sample_data['data1.json'])
      end

      it 'handles authentication in URL' do
        allow(supplier).to receive(:supplier_remote_source).and_return('ftp://user:pass@example.com/path/data.json')

        supplier.read_from_remote
        expect(ftp_double).to have_received(:login).with('user', 'pass')
      end

      it 'handles glob patterns in path' do
        allow(supplier).to receive(:supplier_remote_source).and_return('ftp://example.com/path/*.json')

        result = supplier.read_from_remote
        expect(result[:articles]).to contain_exactly({ name: 'Article 1', price: 1.99 }, { name: 'Article 2', price: 2.99 })
      end

      it 'returns empty articles array when no files match the pattern' do
        allow(supplier).to receive(:supplier_remote_source).and_return('ftp://example.com/path/*.json')
        allow(ftp_double).to receive(:nlst).and_return(['other.txt'])

        result = supplier.read_from_remote
        expect(result).to eq({ articles: [] })
      end
    end
  end

  it 'return correct tolerance' do
    supplier = create(:supplier)
    supplier.articles = create_list(:article, 1, unit_quantity: 1)
    expect(supplier.has_tolerance?).to be false
    supplier2 = create(:supplier)
    supplier2.articles = create_list(:article, 1, unit_quantity: 2)
    expect(supplier2.has_tolerance?).to be true
  end

  it 'deletes the supplier and its articles' do
    supplier = create(:supplier, article_count: 3)
    supplier.articles.each { |a| allow(a).to receive(:mark_as_deleted) }
    supplier.mark_as_deleted
    supplier.articles.each { |a| expect(a).to have_received(:mark_as_deleted) }
    expect(supplier.deleted?).to be true
  end

  it 'has a unique name' do
    supplier2 = build(:supplier, name: supplier.name)
    expect(supplier2).to be_invalid
  end

  it 'has valid articles' do
    supplier = create(:supplier, article_count: true)
    supplier.articles.each { |a| expect(a).to be_valid }
  end
end
