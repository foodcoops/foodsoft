require_relative '../spec_helper'

feature GroupOrderInvoice, js: true do
  let(:admin) { create :user, groups: [create(:workgroup, role_finance: true)] }
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:article) { create :article, unit_quantity: 1 }
  let(:order) { create :order, supplier: article.supplier, article_ids: [article.id], ends: Time.now } # need to ref article
  let(:go) { create :group_order, order: order, ordergroup: user.ordergroup}
  let(:oa) { order.order_articles.find_by_article_id(article.id) }
  let(:ftt) { create :financial_transaction_type }
  let(:goa) { create :group_order_article, group_order: go, order_article: oa }

  include ActiveJob::TestHelper

  before { login admin }

  after { clear_enqueued_jobs }

  it 'does not enqueue MailerJob when order is settled if tax_number or options not set' do
    goa.update_quantities 2, 0
    oa.update_results!
    visit confirm_finance_order_path(id: order.id)
    click_link_or_button I18n.t('finance.balancing.confirm.clear')
    expect(NotifyGroupOrderInvoiceJob).not_to have_been_enqueued
  end

  it 'enqueues MailerJob when order is settled if tax_number or options are set' do
    goa.update_quantities 2, 0
    oa.update_results!
    order.reload
    FoodsoftConfig[:group_order_invoices] = { use_automatic_invoices: true }
    FoodsoftConfig[:contact][:tax_number] = 12_345_678
    visit confirm_finance_order_path(id: order.id, type: ftt)
    expect(page).to have_selector(:link_or_button, I18n.t('finance.balancing.confirm.clear'))
    click_link_or_button I18n.t('finance.balancing.confirm.clear')
    expect(NotifyGroupOrderInvoiceJob).to have_been_enqueued
  end
  
  it 'generates Group Order Invoice when order is closed if tax_number is set' do
    goa.update_quantities 2, 0
    oa.update_results!
    FoodsoftConfig[:contact][:tax_number] = 12_345_678
    order.update!(state: 'closed')
    order.reload
    visit finance_order_index_path
    expect(page).to have_selector(:link_or_button, I18n.t('activerecord.attributes.group_order_invoice.links.generate'))
    click_link_or_button I18n.t('activerecord.attributes.group_order_invoice.links.generate')
    expect(GroupOrderInvoice.all.count).to eq(1)
  end
    
  it 'generates multiple Group Order Invoice for order when order is closed if tax_number is set' do
    goa.update_quantities 2, 0
    oa.update_results!
    FoodsoftConfig[:contact][:tax_number] = 12_345_678
    order.update!(state: 'closed')
    order.reload
    visit finance_order_index_path
    expect(page).to have_selector(:link_or_button, I18n.t('activerecord.attributes.group_order_invoice.links.generate_with_date'))
    click_link_or_button I18n.t('activerecord.attributes.group_order_invoice.links.generate_with_date')
    expect(GroupOrderInvoice.all.count).to eq(1)
  end

  it 'does not generate Group Order Invoice when order is closed if tax_number not set' do
    goa.update_quantities 2, 0
    oa.update_results!
    order.update!(state: 'closed')
    order.reload
    visit finance_order_index_path
    expect(page).to have_content(I18n.t('activerecord.attributes.group_order_invoice.tax_number_not_set'))
  end
end
