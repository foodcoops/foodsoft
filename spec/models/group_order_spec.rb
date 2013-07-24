require 'spec_helper'

describe GroupOrder do
  let(:user) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:supplier) { FactoryGirl.create :supplier, article_count: true }
  let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).reload }

  # the following two tests are currently disabled - https://github.com/foodcoops/foodsoft/issues/158

  #it 'needs an order' do
  #  expect(FactoryGirl.build(:group_order, ordergroup: user.ordergroup)).to be_invalid
  #end

  #it 'needs an ordergroup' do
  #  expect(FactoryGirl.build(:group_order, order: order)).to be_invalid
  #end

  describe do
    let(:go) { FactoryGirl.create :group_order, order: order, ordergroup: user.ordergroup }

    it 'has zero price initially' do
      expect(go.price).to eq(0)
    end
  end

end
