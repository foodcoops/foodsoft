require_relative '../spec_helper'

describe Order do

  it 'needs a supplier' do
    expect(build(:order, supplier: nil)).to be_invalid
  end

  it 'needs order articles' do
    supplier = create :supplier, article_count: 0
    expect(build(:order, supplier: supplier)).to be_invalid
  end

  it 'can be created' do
    expect(build(:order, article_count: 1)).to be_valid
  end

  describe 'with articles' do
    let(:order) { create :order }

    it 'is open by default'         do expect(order).to be_open end
    it 'is not finished by default' do expect(order).to_not be_finished end
    it 'is not closed by default'   do expect(order).to_not be_closed end

    it 'has valid order articles' do
      order.order_articles.each {|oa| expect(oa).to be_valid }
    end

    it 'can be finished' do
      # TODO randomise user
      order.finish!(User.first)
      expect(order).to_not be_open
      expect(order).to be_finished
      expect(order).to_not be_closed
    end

    it 'can be closed' do
      # TODO randomise user
      order.finish!(User.first)
      order.close!(User.first)
      expect(order).to_not be_open
      expect(order).to be_closed
    end

  end

end
