# frozen_string_literal: true

require 'spec_helper'
require 'foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  odin_files_path = File.join(files_path, 'odin')

  dummy_article = { order_number: '0109', name: 'nucli rose', note: 'Biologisch', manufacturer: 'NELEMAN',
                    origin: 'ES', unit: '750gr', price: '4.52', tax: '21', deposit: '0', article_category: '',
                    minimum_order_quantity: 1, group_order_granularity: 1, availability: true, article_unit_ratios: [{ sort: 1, quantity: '6', unit: 'XPP' }],
                    billing_unit: 'XPP', supplier_order_unit: nil, price_unit: 'XPP', group_order_unit: 'XPP' }

  empty = {}

  context 'with type odin/dnb_xml' do
    it 'parses file correctly with type parameter dnb_xml' do
      described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),
                            type: 'dnb_xml') do |new_attrs, status, _line|
        expect(new_attrs).to eq dummy_article
        expect(status).to be_nil
      end
    end

    it 'parses file correctly with type parameter odin' do
      described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),
                            type: 'odin') do |new_attrs, status, _line|
        expect(new_attrs).to eq dummy_article
        expect(status).to be_nil
      end
    end

    it 'raises error wenn wrong type specified' do
      expect do
        described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),
                              type: 'foodsoft')
      end.to raise_error(RuntimeError)
      expect do
        described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),
                              type: 'bioromeo')
      end.to raise_error(RuntimeError)

      expect do
        described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),
                              type: 'bnn')
      end.to raise_error(CSV::MalformedCSVError)
    end

    it 'parses missing entries correctly' do
      described_class.parse(File.open(File.join(odin_files_path, 'odin_missing_entries.xml')),
                            type: 'odin') do |new_attrs, status, _line|
        expect(status).to eq :outlisted
        expect(new_attrs[:unit]).to eq '750st'
        expect(new_attrs[:manufacturer]).to eq ''
      end
    end

    it 'skips rows without order_number' do
      described_class.parse(File.open(File.join(odin_files_path, 'odin_missing_order_number.xml')),
                            type: 'odin') do |new_attrs, _status, _line|
        expect(new_attrs).to eq empty
      end
    end

    it 'joins custom_codes file' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      described_class.parse(File.open(File.join(odin_files_path, 'odin_flawless_custom_category.xml')),
                            custom_file_path: custom_file_path, type: 'odin') do |new_attrs, _status, _line|
        expect(new_attrs[:article_category]).to eq 'Test Indeling - Test Subindeling'
      end
    end

    it 'parses dummy_article with special correctly', skip: 'fails with "No such file or directory"' do
      # TODO: find out whether there are special prices for odin files
      described_class.parse(File.open(File.join(odin_files_path, 'bnn_flawless_special.BNN')),
                            type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs.manufacturer).to be_nil
        expect(new_attrs.unit).to eq '750st'
      end
    end

    it 'parses file with different encoding', skip: 'fails with "No such file or directory"' do
      # the bnn file is loaded with encoding ibm850. If file is not ibm850 encoded, some characters might look weird
      described_class.parse(File.open(File.join(odin_files_path, 'bnn_bad_encoding.BNN')),
                            type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs[:order_number]).to eq('64721')
        expect(new_attrs[:name]).to eq('Greek Dressing - Kr├ñuter Mix')
      end
    end
  end
end
