require_relative '../spec_helper'

describe GroupOrder do
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:order) { create :order }

  # the following two tests are currently disabled - https://github.com/foodcoops/foodsoft/issues/158

  # it 'needs an order' do
  #   expect(FactoryBot.build(:group_order, ordergroup: user.ordergroup)).to be_invalid
  # end

  # it 'needs an ordergroup' do
  #   expect(FactoryBot.build(:group_order, order: order)).to be_invalid
  # end

  describe do
    let(:go) { create :group_order, order: order, ordergroup: user.ordergroup }

    it 'has zero price initially' do
      expect(go.price).to eq(0)
    end
  end
end
