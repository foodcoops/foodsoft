require_relative '../spec_helper'

feature Order, :js do
  let(:admin) { create(:user, groups: [create(:workgroup, role_orders: true)]) }
  let(:article) { create(:article, unit_quantity: 1) }
  let(:order) { create(:order, supplier: article.supplier, article_ids: [article.id]) } # need to ref article
  let(:go1) { create(:group_order, order: order) }
  let(:oa) { order.order_articles.find_by_article_version_id(article.latest_article_version.id) }
  let(:goa1) { create(:group_order_article, group_order: go1, order_article: oa) }

  before { login admin }

  it 'can get to the new order page' do
    article.supplier
    visit orders_path
    click_link_or_button I18n.t('orders.index.new_order')
    click_link_or_button order.name
    expect(page).to have_text I18n.t('orders.new.title')
    expect(page).to have_text article.name
  end

  it 'fills in the end date with a schedule' do
    FoodsoftConfig[:time_zone] = 'UTC'
    FoodsoftConfig[:order_schedule] = { ends: { recurr: 'FREQ=MONTHLY;BYMONTHDAY=1', time: '12:00' } }
    visit new_order_path(supplier_id: article.supplier.id)
    expect(page).to have_text I18n.t('orders.new.title')
    expect(find_field('order_ends_time_value').value).to eq '12:00'
    expect(find_field('order_ends_date_value').value).to eq Date.today.next_month.at_beginning_of_month.strftime('%Y-%m-%d')
  end

  it 'can create a new order' do
    visit new_order_path(supplier_id: article.supplier_id)
    expect(page).to have_text I18n.t('orders.new.title')
    find('input[type="submit"]').click
    expect(page).to have_css('.alert-success')
    expect(Order.count).to eq 1
    expect(Order.first.supplier).to eq article.supplier
  end

  it 'can close an order' do
    setup_and_close_order
    expect(order).to be_finished
    expect(page).to have_no_link I18n.t('orders.index.action_end')
    expect(oa.units_to_order).to eq 1
  end

  def setup_and_close_order
    # have at least something ordered
    goa1.update_quantities 1, 0
    oa.update_results!
    # and close the order
    visit orders_path
    accept_confirm do
      click_link_or_button I18n.t('orders.index.action_end')
    end
    expect(page).to have_css('.alert-success')
    order.reload
    oa.reload
  end
end
