require_relative '../test_helper'
require_relative '../../../../spec/spec_helper'

describe Supplier do
  let(:supplier) { create :supplier }

  context 'syncs from file' do
    it 'imports and updates articles' do
      article1 = create(:article, supplier: supplier, order_number: 177813, unit: '250 g', price: 0.1)
      article2 = create(:article, supplier: supplier, order_number: 12345)
      supplier.articles = [article1, article2]
      options = { filename: 'foodsoft_file_01.csv' }
      options[:outlist_absent] = true
      options[:convert_units] = true
      updated_article_pairs, outlisted_articles, new_articles = supplier.sync_from_file(Rails.root.join('spec/fixtures/foodsoft_file_01.csv'), 'foodsoft', options)
      expect(new_articles.length).to be > 0
      expect(updated_article_pairs.first[1][:name]).to eq 'Tomaten'
      expect(outlisted_articles.first).to eq article2
    end
  end
end