# frozen_string_literal: true

require 'spec_helper'
require 'foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  foodsoft_files_path = File.join(files_path, 'foodsoft')

  dummy_article = { availability: false, order_number: '1', name: 'product', note: 'bio', manufacturer: 'someone', origin: 'eu',
                    unit: '1 kg', price: '1.23', tax: '6', article_category: 'coolstuff', deposit: '0',
                    article_unit_ratios: [], billing_unit: nil, group_order_granularity: nil, group_order_unit: nil,
                    minimum_order_quantity: nil, price_unit: nil, supplier_order_unit: nil }

  dummy_article2 = { availability: false, order_number: '12', name: 'other product', note: 'bio', manufacturer: 'someone',
                     origin: 'eu', unit: '2 kg', price: '3.45', tax: '6', article_category: 'coolstuff', deposit: '0',
                     article_unit_ratios: [], billing_unit: nil, group_order_granularity: nil, group_order_unit: nil,
                     minimum_order_quantity: nil, price_unit: nil, supplier_order_unit: nil }

  articles = [dummy_article, dummy_article2]

  dummy_article3 = dummy_article.merge({ order_number: ':c72fb13' })
  dummy_article4 = dummy_article2.merge({ order_number: ':cd9ffa6' })
  articles_number_generated = [dummy_article3, dummy_article4]

  context 'with type foodsoft' do
    it 'parses foodsoft file correctly without type parameter' do
      count = 0
      described_class.parse(File.open(File.join(foodsoft_files_path,
                                                'foodsoft_flawless.csv'))) do |new_attrs, status, _line|
        expect(new_attrs).to eq articles[count]
        expect(status).to be_nil
        count += 1
      end
    end

    it 'parses file correctly with type parameter foodsoft' do
      count = 0
      described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')),
                            type: 'foodsoft_spreadsheet') do |new_attrs, status, _line|
        expect(new_attrs).to eq articles[count]
        expect(status).to be_nil
        count += 1
      end
    end

    it 'raises error wenn wrong type specified' do
      expect do
        described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')),
                              type: 'bioromeo')
      end.to raise_error(Roo::HeaderRowNotFoundError)
      expect(described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')),
                                   type: 'odin')).to eq []

      expect(described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')),
                                   type: 'bnn')).to eq []
    end

    it 'parses missing entries correctly' do
      described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_missing_entries.csv')),
                            type: 'foodsoft_spreadsheet') do |new_attrs, status, _line|
        expect(status).to be_nil
        expect(new_attrs[:unit]).to eq '1 kg'
        expect(new_attrs[:manufacturer]).to be_nil
      end
    end

    it 'generates order numbers for articles without order number' do
      count = 0
      described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_generate_order_number.csv')),
                            type: 'foodsoft_spreadsheet') do |new_attrs, _status, _line|
        expect(new_attrs).to eq articles_number_generated[count]
        count += 1
      end
    end

    it 'joins custom_codes file', skip: 'fails with "No such file or directory"' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      described_class.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless_custom_category.csv')),
                            custom_file_path: custom_file_path, type: 'foodsoft') do |new_attrs, _status, _line|
        expect(new_attrs[:article_category]).to eq 'Test Indeling - Test Subindeling'
      end
    end
  end
end
