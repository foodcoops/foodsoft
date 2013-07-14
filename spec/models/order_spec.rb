require 'spec_helper'

describe Order do

  it 'needs a supplier' do
    FactoryGirl.build(:order).should_not be_valid
  end

  it 'needs order articles' do
    supplier = FactoryGirl.create :supplier, article_count: 0
    FactoryGirl.build(:order, supplier: supplier).should_not be_valid
  end

  it 'can be created' do
    supplier = FactoryGirl.create :supplier, article_count: 1
    FactoryGirl.build(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).should be_valid
  end

  describe 'with articles' do
    let(:supplier) { FactoryGirl.create :supplier, article_count: true }
    let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).reload }

    it 'is open by default'         do order.open?.should be_true end
    it 'is not finished by default' do order.finished?.should be_false end
    it 'is not closed by default'   do order.closed?.should be_false end

    it 'has valid order articles' do
      order.order_articles.all.each {|oa| oa.should be_valid }
    end

    it 'can be finished' do
      # TODO randomise user
      order.finish!(User.first)
      order.open?.should be_false
      order.finished?.should be_true
      order.closed?.should be_false
    end

    it 'can be closed' do
      # TODO randomise user
      order.finish!(User.first)
      order.close!(User.first)
      order.open?.should be_false
      order.closed?.should be_true
    end

  end

end
