require_relative '../spec_helper'

describe Order do
  let(:user) { create :user, groups: [create(:ordergroup)] }

  it 'automaticly finishes ended' do
    create :order, created_by: user, starts: Date.yesterday, ends: 1.hour.from_now
    create :order, created_by: user, starts: Date.yesterday, ends: 1.hour.ago
    create :order, created_by: user, starts: Date.yesterday, ends: 1.hour.from_now, end_action: :auto_close
    order = create :order, created_by: user, starts: Date.yesterday, ends: 1.hour.ago, end_action: :auto_close

    Order.finish_ended!
    order.reload

    expect(Order.open.count).to eq 3
    expect(Order.finished.count).to eq 1
    expect(order).to be_finished
  end

  describe 'scopes' do
    let!(:open_order)     { create :order, state: 'open'     }
    let!(:finished_order) { create :order, state: 'finished' }
    let!(:received_order) { create :order, state: 'received' }
    let!(:closed_order)   { create :order, state: 'closed'   }

    it 'should retrieve open orders in the "open" scope' do
      expect(Order.open.count).to eq(1)
      expect(Order.open.where(id: open_order.id)).to exist
    end

    it 'should retrieve finished, received and closed orders in the "finished" scope' do
      expect(Order.finished.count).to eq(3)
      expect(Order.finished.where(id: finished_order.id)).to exist
      expect(Order.finished.where(id: received_order.id)).to exist
      expect(Order.finished.where(id: closed_order.id)).to exist
    end

    it 'should retrieve finished and received orders in the "finished_not_closed" scope' do
      expect(Order.finished_not_closed.count).to eq(2)
      expect(Order.finished_not_closed.where(id: finished_order.id)).to exist
      expect(Order.finished_not_closed.where(id: received_order.id)).to exist
    end
  end

  it 'sends mail if min_order_quantity has been reached' do
    create :user, groups: [create(:ordergroup)]
    create :order, created_by: user, starts: Date.yesterday, ends: 1.hour.ago, end_action: :auto_close_and_send_min_quantity

    Order.finish_ended!
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

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
      order.finish!(user)
      expect(order).to_not be_open
      expect(order).to be_finished
      expect(order).to_not be_closed
    end

    it 'can be closed' do
      # TODO randomise user
      order.finish!(user)
      order.close!(user)
      expect(order).to_not be_open
      expect(order).to be_closed
    end

  end

  describe 'with a default end date' do
    let(:order) { create :order }
    before do
      FoodsoftConfig[:order_schedule] = {ends: {recurr: 'FREQ=WEEKLY;BYDAY=MO', time: '9:00'}}
      order.init_dates
    end

    it 'to have a correct date' do
      expect(order.ends.to_date).to eq Date.today.next_week.at_beginning_of_week(:monday)
    end

    it 'to have a correct time' do
      expect(order.ends.strftime('%H:%M')).to eq '09:00'
    end

  end

  describe 'mapped to GroupOrders' do
    let!(:user) { create :user, groups: [create(:ordergroup)] }
    let!(:order) { create :order }
    let!(:order2) { create :order }
    let!(:go) { create :group_order, order: order, ordergroup: user.ordergroup }

    it 'to map a user\'s GroupOrders to a list of Orders' do
      orders = Order.ordergroup_group_orders_map(user.ordergroup)

      expect(orders.length).to be 2
      expect(orders[0][:order]).to have_attributes(id: order.id)
      expect(orders[0][:group_order]).to have_attributes(id: go.id)
      expect(orders[1][:order]).to have_attributes(id: order2.id)
      expect(orders[1][:group_order]).to be_nil
    end
  end

end
