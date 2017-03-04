require_relative '../spec_helper'

feature 'product distribution', js: true do
  let(:ftt) { create :financial_transaction_type }
  let(:admin) { create :admin }
  let(:user_a) { create :user, groups: [create(:ordergroup)] }
  let(:user_b) { create :user, groups: [create(:ordergroup)] }
  let(:supplier) { create :supplier }
  let(:article) { create :article, supplier: supplier, unit_quantity: 5 }
  let(:order) { create(:order, supplier: supplier, article_ids: [article.id]) }
  let(:oa) { order.order_articles.first }

  before do
    # make sure users have enough money to order
    [user_a, user_b].each do |user|
      ordergroup = Ordergroup.find(user.ordergroup.id)
      ordergroup.add_financial_transaction! 5000, 'for ordering', admin, ftt
    end
    order # make sure order is referenced
  end

  it 'agrees to documented example' do
    # gruppe a bestellt 2(3), weil sie auf jeden fall was von x bekommen will
    login user_a
    visit new_group_order_path(order_id: order.id)
    scrolldown
    2.times { find("[data-increase_quantity='#{oa.id}']").click }
    3.times { find("[data-increase_tolerance='#{oa.id}']").click }
    find('input[type=submit]').click
    expect(page).to have_selector('body')
    # gruppe b bestellt 2(0)
    login user_b
    visit new_group_order_path(order_id: order.id)
    scrolldown
    2.times { find("[data-increase_quantity='#{oa.id}']").click }
    find('input[type=submit]').click
    expect(page).to have_selector('body')
    # gruppe a faellt ein dass sie doch noch mehr braucht von x und aendert auf 4(1).
    login user_a
    visit edit_group_order_path(id: order.group_order(user_a.ordergroup).id, order_id: order.id)
    scrolldown
    2.times { find("[data-increase_quantity='#{oa.id}']").click }
    2.times { find("[data-decrease_tolerance='#{oa.id}']").click }
    find('input[type=submit]').click
    expect(page).to have_selector('body')
    # die zuteilung
    order.finish!(admin)
    oa.reload
    # Endstand: insg. Bestellt wurden 6(1)
    expect(oa.quantity).to eq(6)
    expect(oa.tolerance).to eq(1)
    # Gruppe a bekommt 3 einheiten.
    goa_a = oa.group_order_articles.joins(:group_order).where(:group_orders => {:ordergroup_id => user_a.ordergroup.id}).first
    expect(goa_a.result).to eq(3)
    # gruppe b bekommt 2 einheiten.
    goa_b = oa.group_order_articles.joins(:group_order).where(:group_orders => {:ordergroup_id => user_b.ordergroup.id}).first
    expect(goa_b.result).to eq(2)
  end
end
