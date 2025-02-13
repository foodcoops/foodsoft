# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  bnn_files_path = File.join(files_path, 'bnn')

  dummy_article = { name: 'Greek Dressing - Kräuter Mix', order_number: '64721', note: 'Oregano, Basilikum und Minze',
                    manufacturer: 'Medousa, Griechenland Importe', origin: 'GR', article_category: 'Kräutermischungen', unit: '35g', price: '2,89', tax: 7.0, unit_quantity: '6' }

  article = dummy_article.merge({ deposit: 0.08 })
  article_special = article.merge(note: 'Sonderpreis: 2,89 von 20230101 bis 20230201')

  article_2 = dummy_article.merge({ manufacturer: nil, article_category: nil })

  article_custom_code = article.merge(article_category: 'Schuhe')

  empty = {}

  context 'bnn' do
    it 'parses bnn file correctly without type parameter' do
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path,                     'bnn_flawless.BNN'))) do |new_attrs, status, _line|
        expect(new_attrs).to eq article
        expect(status).to eq :outlisted
      end
    end
    it 'parses file correctly with type parameter' do
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')), type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article
        expect(status).to eq :outlisted
      end
    end
    it 'raises error wenn wrong type (except odin) specified' do
      expect do
        FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),   type: 'foodsoft')
      end.to raise_error(RuntimeError)

      expect(FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_flawless.BNN')),        type: 'odin')).to eq []
    end
    it 'parses article with special correctly' do
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_flawless_special.BNN')), type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article_special
        expect(status).to eq :special
      end
    end
    it 'parses missing entries correctly' do
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_missing_entries.BNN')), type: 'bnn') do |new_attrs, status, _line|
        expect(new_attrs).to eq article_2
        expect(status).to eq nil
      end
    end
    it 'skips rows without order_number' do
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_missing_order_number.BNN')), type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs).to eq empty
      end
    end
    it 'joins custom_codes file' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_flawless_category.BNN')), custom_file_path: custom_file_path, type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs).to eq article_custom_code
      end
    end
    it 'parses file with different encoding' do
      # the bnn file is loaded with encoding ibm850. If file is not ibm850 encoded, some characters might look weird
      FoodsoftArticleImport.parse(File.open(File.join(bnn_files_path, 'bnn_bad_encoding.BNN')), type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs[:order_number]).to eq('64721')
        expect(new_attrs[:name]).to eq('Greek Dressing - Kr├ñuter Mix')
      end
    end
  end
end
