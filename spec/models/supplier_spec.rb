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
      options[:convert_units] = true
      updated_article_pairs, outlisted_articles, new_articles = supplier.sync_from_file(
        Rails.root.join('spec/fixtures/foodsoft_file_01.csv'), options
      )
      expect(new_articles.length).to be > 0
      expect(updated_article_pairs.first[1][:name]).to eq 'Tomaten'
      expect(outlisted_articles.first).to eq article2
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
