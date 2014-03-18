require_relative '../spec_helper'

describe 'receiving an order', :type => :feature do
  let(:admin) { create :user, groups:[create(:workgroup, role_orders: true)] }
  let(:supplier) { create :supplier }
  let(:article) { create :article, supplier: supplier, unit_quantity: 3 }
  let(:order) { create :order, supplier: supplier, article_ids: [article.id] } # need to ref article
  let(:go1) { create :group_order, order: order }
  let(:go2) { create :group_order, order: order }
  let(:oa) { order.order_articles.find_by_article_id(article.id) }
  let(:goa1) { create :group_order_article, group_order: go1, order_article: oa }
  let(:goa2) { create :group_order_article, group_order: go2, order_article: oa }

  # set quantities of group_order_articles
  def set_quantities(q1, q2)
    goa1.update_quantities(*q1)
    goa2.update_quantities(*q2)
    oa.update_results!
    order.finish!(admin)
    reload_articles
  end

  # reload all group_order_articles
  def reload_articles
    goa1.reload unless goa1.destroyed?
    goa2.reload unless goa2.destroyed?
    oa.reload
  end

  def check_quantities(units, q1, q2)
    reload_articles
    expect(oa.units).to eq units
    expect(goa1.destroyed? ? 0 : goa1.result).to be_within(1e-3).of q1
    expect(goa2.destroyed? ? 0 : goa2.result).to be_within(1e-3).of q2
  end


  describe :type => :feature, :js => true do
    before { login admin }

    it 'has product ordered visible' do
      set_quantities [3,0], [0,0]
      visit receive_order_path(order)
      expect(page).to have_content(article.name)
      expect(page).to have_selector("#order_article_#{oa.id}")
    end

    it 'has product not ordered invisible' do
      set_quantities [0,0], [0,0]
      visit receive_order_path(order)
      expect(page).to_not have_selector("#order_article_#{oa.id}")
    end

    it 'is not received by default' do
      set_quantities [3,0], [0,0]
      visit receive_order_path(order)
      expect(find("#order_articles_#{oa.id}_units_received").value).to eq ''
    end

    it 'does not change anything when received is ordered' do
      set_quantities [2,0], [3,2]
      visit receive_order_path(order)
      fill_in "order_articles_#{oa.id}_units_received", :with => oa.units_to_order
      find('input[type="submit"]').click
      expect(page).to have_selector('body')
      check_quantities 2,  2, 4
    end

    it 'redistributes properly when received is more' do
      set_quantities [2,0], [3,2]
      visit receive_order_path(order)
      fill_in "order_articles_#{oa.id}_units_received", :with => 3
      find('input[type="submit"]').click
      expect(page).to have_selector('body')
      check_quantities 3,  2, 5
    end

    it 'redistributes properly when received is less' do
      set_quantities [2,0], [3,2]
      visit receive_order_path(order)
      fill_in "order_articles_#{oa.id}_units_received", :with => 1
      find('input[type="submit"]').click
      expect(page).to have_selector('body')
      check_quantities 1,  2, 1
    end

    it 'has a locked field when edited elsewhere' do
      set_quantities [2,0], [3,2]
      goa1.result = goa1.result + 1
      goa1.save!
      visit receive_order_path(order)
      expect(find("#order_articles_#{oa.id}_units_received")).to be_disabled
    end

    it 'leaves locked rows alone when submitted' do
      set_quantities [2,0], [3,2]
      goa1.result = goa1.result + 1
      goa1.save!
      visit receive_order_path(order)
      find('input[type="submit"]').click
      expect(page).to have_selector('body')
      check_quantities 2,  3, 4
    end

  end

end
