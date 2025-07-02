require 'spec_helper'

describe FoodsoftB85::OrderB85 do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:supplier) { create(:supplier, customer_number: '123456', article_count: 2) }
  let(:order) { create(:order, supplier: supplier, created_by: user, starts: Date.yesterday, ends: 1.hour.ago) }
  let(:articles) { order.articles }
  let(:order_articles) { order.order_articles }
  let(:first_article_version) { articles.first&.latest_article_version }
  let(:second_article_version) { articles.second&.latest_article_version }

  before do
    # Set specific properties on the articles
    first_article_version.update(name: 'Test Article 1', order_number: '1234567890123')
    second_article_version.update(name: 'Test Article 2', order_number: '9876543210987')

    # Set order quantities
    order_articles.where(article_version: first_article_version).first&.update(units_to_order: 5)
    order_articles.where(article_version: second_article_version).first&.update(units_to_order: 2.5)
  end

  it 'creates a proper B85 format output from an order' do
    result = described_class.new(order).to_remote_format

    # Verify the header
    expect(result).to start_with('D#123456000000 ')

    # Verify the article data
    expect(result).to include('1234567890123+0005000Test Article 1                0001000Piece')
    expect(result).to include('9876543210987+0002500Test Article 2                0001000Piece')

    # Verify the encoding
    expect(result.encoding).to eq(Encoding::ISO_8859_1)

    # Verify the end of dataset markers
    expect(result.scan("\r\n").count).to eq(3)
  end
end
