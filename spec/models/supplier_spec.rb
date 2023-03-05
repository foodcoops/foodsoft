require_relative '../spec_helper'

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
      updated_article_pairs, outlisted_articles, new_articles = supplier.sync_from_file(Rails.root.join('spec/fixtures/foodsoft_file_01.csv'), options)
      expect(new_articles.length).to be > 0
      expect(updated_article_pairs.first[1][:name]).to eq 'Tomaten'
      expect(outlisted_articles.first).to eq article2
    end
  end

  it 'return correct tolerance' do
    supplier = create :supplier, articles: create_list(:article, 1, unit_quantity: 1)
    expect(supplier.has_tolerance?).to be false
    supplier2 = create :supplier, articles: create_list(:article, 1, unit_quantity: 2)
    expect(supplier2.has_tolerance?).to be true
  end

  it 'deletes the supplier and its articles' do
    supplier = create :supplier, article_count: 3
    supplier.articles.each { |a| allow(a).to receive(:mark_as_deleted) }
    supplier.mark_as_deleted
    supplier.articles.each { |a| expect(a).to have_received(:mark_as_deleted) }
    expect(supplier.deleted?).to be true
  end

  it 'has a unique name' do
    supplier2 = build :supplier, name: supplier.name
    expect(supplier2).to be_invalid
  end

  it 'has valid articles' do
    supplier = create :supplier, article_count: true
    supplier.articles.each { |a| expect(a).to be_valid }
  end

  context 'connected to a shared supplier' do
    let(:shared_sync_method) { nil }
    let(:shared_supplier) { create :shared_supplier }
    let(:supplier) { create :supplier, shared_supplier: shared_supplier, shared_sync_method: shared_sync_method }

    let!(:synced_shared_article) { create :shared_article, shared_supplier: shared_supplier }
    let!(:updated_shared_article) { create :shared_article, shared_supplier: shared_supplier }
    let!(:new_shared_article) { create :shared_article, shared_supplier: shared_supplier }

    let!(:removed_article) { create :article, supplier: supplier, order_number: '10001-ABC' }
    let!(:updated_article) do
      updated_shared_article.build_new_article(supplier).tap do |article|
        article.article_category = create :article_category
        article.origin = "FubarX1"
        article.shared_updated_on = 1.day.ago
        article.save!
      end
    end
    let!(:synced_article) do
      synced_shared_article.build_new_article(supplier).tap do |article|
        article.article_category = create :article_category
        article.shared_updated_on = 1.day.ago
        article.save!
      end
    end

    context 'with sync method import' do
      let(:shared_sync_method) { 'import' }

      it 'returns the expected articles' do
        updated_article_pairs, outlisted_articles, new_articles = supplier.sync_all

        expect(updated_article_pairs).to_not be_empty
        expect(updated_article_pairs[0][0].id).to eq updated_article.id
        expect(updated_article_pairs[0][1].keys).to include :origin

        expect(outlisted_articles).to eq [removed_article]

        expect(new_articles).to be_empty
      end
    end

    context 'with sync method all_available' do
      let(:shared_sync_method) { 'all_available' }

      it 'returns the expected articles' do
        updated_article_pairs, outlisted_articles, new_articles = supplier.sync_all

        expect(updated_article_pairs).to_not be_empty
        expect(updated_article_pairs[0][0].id).to eq updated_article.id
        expect(updated_article_pairs[0][1].keys).to include :origin

        expect(outlisted_articles).to eq [removed_article]

        expect(new_articles).to_not be_empty
        expect(new_articles[0].order_number).to eq new_shared_article.number
        expect(new_articles[0].availability?).to be true
      end
    end

    context 'with sync method all_unavailable' do
      let(:shared_sync_method) { 'all_unavailable' }

      it 'returns the expected articles' do
        updated_article_pairs, outlisted_articles, new_articles = supplier.sync_all

        expect(updated_article_pairs).to_not be_empty
        expect(updated_article_pairs[0][0].id).to eq updated_article.id
        expect(updated_article_pairs[0][1].keys).to include :origin

        expect(outlisted_articles).to eq [removed_article]

        expect(new_articles).to_not be_empty
        expect(new_articles[0].order_number).to eq new_shared_article.number
        expect(new_articles[0].availability?).to be false
      end
    end
  end
end
