# frozen_string_literal: true

require 'spec_helper'
require 'foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  foodsoft_files_path = File.join(files_path, 'foodsoft')

  dummy_article = { order_number: '1', name: 'product', note: 'bio', manufacturer: 'someone', origin: 'eu',
                    unit: '1 kg', price: '1.23', tax: '6', unit_quantity: '10', article_category: 'coolstuff', deposit: '0' }

  dummy_article_2 = { order_number: '12', name: 'other product', note: 'bio', manufacturer: 'someone',
                      origin: 'eu', unit: '2 kg', price: '3.45', tax: '6', unit_quantity: '10', article_category: 'coolstuff', deposit: '0' }

  articles = [dummy_article, dummy_article_2]

  dummy_article_3 = dummy_article.merge({ order_number: ':d8df298' })
  dummy_article_4 = dummy_article_2.merge({ order_number: ':1f37e39' })
  articles_number_generated = [dummy_article_3, dummy_article_4]
  empty = {}

  context 'foodsoft' do
    it 'parses file correctly with type parameter foodsoft' do
      count = 0
      FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')), type: 'foodsoft') do |new_attrs, status, _line|
        expect(new_attrs).to eq articles[count]
        expect(status).to eq nil
        count += 1
      end
    end

    it 'raises error wenn wrong type specified' do
      expect(FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')), type: 'odin')).to eq []

      expect(FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless.csv')), type: 'bnn')).to eq []
    end

    it 'parses missing entries correctly' do
      FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_missing_entries.csv')), type: 'foodsoft') do |new_attrs, status, _line|
        expect(status).to eq 'Error: unit, price and tax must be entered'
        expect(new_attrs[:unit]).to eq '1 kg'
        expect(new_attrs[:manufacturer]).to eq nil
      end
    end

    it 'generates order numbers for articles without order number' do
      count = 0
      FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_generate_order_number.csv')), type: 'foodsoft') do |new_attrs, _status, _line|
        expect(new_attrs).to eq articles_number_generated[count]
        count += 1
      end
    end

    xit 'joins custom_codes file' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      FoodsoftArticleImport.parse(File.open(File.join(foodsoft_files_path, 'foodsoft_flawless_custom_category.csv')), custom_file_path: custom_file_path, type: 'foodsoft') do |new_attrs, _status, _line|
        expect(new_attrs[:article_category]).to eq 'Test Indeling - Test Subindeling'
      end
    end
  end
end
