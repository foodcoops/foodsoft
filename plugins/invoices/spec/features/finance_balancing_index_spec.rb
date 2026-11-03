require 'spec_helper'

describe 'Finance Balancing index shows MultiOrders and finished orders', :js do
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let(:user)  { create(:user, groups: [create(:ordergroup)]) }
  let(:supplier) { create(:supplier) }
  let(:article)  { create(:article, supplier: supplier) }

  before do
    FoodsoftInvoices.enable_extensions!
    login admin
  end

  it 'lists a finished single order and a MultiOrder row' do
    # finished single order
    solo = create(:order, supplier: supplier, article_ids: [article.id])
    create(:group_order, order: solo, ordergroup: user.ordergroup)
    solo.update!(state: 'closed')

    # two closed orders combined into a MultiOrder
    o1 = create(:order, supplier: supplier, article_ids: [article.id])
    o2 = create(:order, supplier: supplier, article_ids: [article.id])
    create(:group_order, order: o1, ordergroup: user.ordergroup)
    create(:group_order, order: o2, ordergroup: user.ordergroup)
    o1.update!(state: 'closed')
    o2.update!(state: 'closed')
    create(:multi_order, orders: [o1, o2])

    visit finance_order_index_path

    # Expect solo order row present
    expect(page).to have_css("tr[data-order_id='#{solo.id}']")

    # Expect both order links to be present (MultiOrder entry rendered)
    expect(page).to have_link(o1.name)
    expect(page).to have_link(o2.name)
  end
end
