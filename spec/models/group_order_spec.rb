require 'spec_helper'

describe GroupOrder do
  let(:user) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:supplier) { FactoryGirl.create :supplier, article_count: true }
  let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).reload }

  it 'needs an order' do
    FactoryGirl.build(:group_order, ordergroup: user.ordergroup).should_not be_valid
  end

  it 'needs an ordergroup' do
    FactoryGirl.build(:group_order, order: order).should_not be_valid
  end

  describe do
    let(:go) { FactoryGirl.create :group_order, order: order, ordergroup: user.ordergroup }

    it 'has zero price initially' do
      go.price.should == 0
    end
  end

end
