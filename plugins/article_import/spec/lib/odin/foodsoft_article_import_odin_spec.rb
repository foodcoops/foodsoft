# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  odin_files_path = File.join(files_path, 'odin')

  dummy_article = { order_number: '0109', name: 'nucli rose', note: 'Biologisch', manufacturer: 'NELEMAN',
                    origin: 'ES', unit: '750gr', price: '4.52', unit_quantity: '6', tax: '21', deposit: '0', article_category: '' }

  empty = {}

  context 'odin' do
    it 'parses file correctly with type parameter odin' do
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')), type: 'odin') do |new_attrs, status, _line|
        expect(new_attrs).to eq dummy_article
        expect(status).to eq nil
      end
    end

    it 'raises error wenn wrong type specified' do
      expect do
        FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),   type: 'foodsoft')
      end.to raise_error(RuntimeError)

      expect do
        FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_flawless.xml')),   type: 'bnn')
      end.to raise_error(CSV::MalformedCSVError)
    end

    it 'parses missing entries correctly' do
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_missing_entries.xml')), type: 'odin') do |new_attrs, status, _line|
        expect(status).to eq :outlisted
        expect(new_attrs[:unit]).to eq '750st'
        expect(new_attrs[:manufacturer]).to eq ''
      end
    end

    it 'skips rows without order_number' do
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_missing_order_number.xml')), type: 'odin') do |new_attrs, _status, _line|
        expect(new_attrs).to eq empty
      end
    end

    it 'joins custom_codes file' do
      custom_file_path = File.join(files_path, 'custom_codes.yml').to_s
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'odin_flawless_custom_category.xml')), custom_file_path: custom_file_path, type: 'odin') do |new_attrs, _status, _line|
        expect(new_attrs[:article_category]).to eq 'Test Indeling - Test Subindeling'
      end
    end

    xit 'parses dummy_article with special correctly' do
      # TODO: find out whether there are special prices for odin files
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'bnn_flawless_special.BNN')), type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs.manufacturer).to eq nil
        expect(new_attrs.unit).to eq '750st'
      end
    end

    xit 'parses file with different encoding' do
      # the bnn file is loaded with encoding ibm850. If file is not ibm850 encoded, some characters might look weird
      FoodsoftArticleImport.parse(File.open(File.join(odin_files_path, 'bnn_bad_encoding.BNN')), type: 'bnn') do |new_attrs, _status, _line|
        expect(new_attrs[:order_number]).to eq('64721')
        expect(new_attrs[:name]).to eq('Greek Dressing - Kr├ñuter Mix')
      end
    end
  end
end
