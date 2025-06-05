# frozen_string_literal: true

require 'spec_helper'
require 'foodsoft_article_import'

describe FoodsoftArticleImport do
  files_path = File.expand_path '../../files', __dir__
  bioromeo_files_path = File.join(files_path, 'bioromeo')

  dummy_article = { order_number: '1', name: 'Wilde aardappels', article_category: 'Aardappels "nieuwe oogst"', article_unit_ratios: [{ quantity: 1, sort: 1, unit: 'XPP' }],
                    deposit: 0, manufacturer: nil, origin: 'Noordoostpolder, NL', price: 5.0, tax: 6, unit: '5kg', note: 'Skal 1234; 123456; Demeter 123456; (Kopervrij)' }

  context 'with type bioromeo' do
    it 'parses file correctly with type parameter bioromeo' do
      described_class.parse(File.open(File.join(bioromeo_files_path, 'bioromeo_flawless.csv')),
                            type: 'bioromeo') do |new_attrs, _status, _line|
        next if new_attrs.nil?

        expect(new_attrs).to eq dummy_article
      end
    end
  end
end
