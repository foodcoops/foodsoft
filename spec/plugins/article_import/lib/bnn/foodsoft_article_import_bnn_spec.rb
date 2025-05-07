# frozen_string_literal: true

require 'spec_helper'
require 'foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  bnn_files_path = File.join(files_path, 'bnn')

  dummy_article = { name: 'Greek Dressing - Kräuter Mix', order_number: '64721', note: 'Oregano, Basilikum und Minze',
                    manufacturer: 'Medousa, Griechenland Importe', origin: 'GR', article_category: 'Kräutermischungen', unit: '6 x35g', price: '2,89', tax: 7.0,
                    minimum_order_quantity: '1', group_order_granularity: 1, availability: true, article_unit_ratios: [{ sort: 1, quantity: '6', unit: 'XPP' }],
                    billing_unit: 'XPP', supplier_order_unit: nil, price_unit: 'XPP', group_order_unit: 'XPP' }

  article = dummy_article.merge({ deposit: 0.08, availability: false })
  article_special = article.merge({ note: 'Sonderpreis: 2,89 von 20230101 bis 20230201', availability: true })

  article2 = dummy_article.merge({ manufacturer: nil, article_category: nil })

  article_custom_code = article.merge({ article_category: 'Schuhe', availability: true })

  empty = {}

  context 'with type bnn' do
    it 'parses file correctly with type parameter' do
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),
                            type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article
        expect(status).to eq :outlisted
      end
    end

    it 'raises error wenn wrong type (except dnb_xml) specified' do
      expect do
        described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),
                              type: 'foodsoft_spreadsheet')
      end.to raise_error(RuntimeError)
      expect do
        described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),
                              type: 'bioromeo')
      end.to raise_error(RuntimeError)

      expect(described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),
                                   type: 'dnb_xml')).to eq []
    end

    it 'parses article with special correctly' do
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless_special.BNN')),
                            type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article_special
        expect(status).to eq :special
      end
    end

    it 'parses missing entries correctly' do
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_missing_entries.BNN')),
                            type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article2
        expect(status).to be_nil
      end
    end

    it 'skips rows without order_number' do
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_missing_order_number.BNN')),
                            type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs).to eq empty
      end
    end

    it 'joins custom_codes file' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_flawless_category.BNN')),
                            custom_file_path: custom_file_path, type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs).to eq article_custom_code
      end
    end

    it 'parses file with different encoding' do
      # the bnn file is loaded with encoding ibm850. If file is not ibm850 encoded, some characters might look weird
      described_class.parse(File.open(File.join(bnn_files_path, 'bnn_bad_encoding.BNN')),
                            type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs[:order_number]).to eq('64721')
        expect(new_attrs[:name]).to eq('Greek Dressing - Kr├ñuter Mix')
      end
    end
  end
end
