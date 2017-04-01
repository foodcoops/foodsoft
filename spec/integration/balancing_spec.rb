require_relative '../spec_helper'

feature 'settling an order', js: true do
  let(:admin) { create :user, groups:[create(:workgroup, role_finance: true)] }
  let(:user) { create :user, groups:[create(:ordergroup)] }
  let(:supplier) { create :supplier }
  let(:article) { create :article, supplier: supplier, unit_quantity: 1 }
  let(:order) { create :order, supplier: supplier, article_ids: [article.id] } # need to ref article
  let(:go1) { create :group_order, order: order }
  let(:go2) { create :group_order, order: order }
  let(:oa) { order.order_articles.find_by_article_id(article.id) }
  let(:goa1) { create :group_order_article, group_order: go1, order_article: oa }
  let(:goa2) { create :group_order_article, group_order: go2, order_article: oa }
  before do
    goa1.update_quantities(3, 0)
    goa2.update_quantities(1, 0)
    oa.update_results!
    order.finish!(admin)
    goa1.reload
    goa2.reload
  end

  it 'has correct order result' do
    expect(oa.quantity).to eq(4)
    expect(oa.tolerance).to eq(0)
    expect(goa1.result).to eq(3)
    expect(goa2.result).to eq(1)
  end

  before { login admin }
  before { visit new_finance_order_path(order_id: order.id) }

  it 'has product ordered visible' do
    expect(page).to have_content(article.name)
    expect(page).to have_selector("#order_article_#{oa.id}")
  end

  it 'shows order result' do
    click_link article.name
    expect(page).to have_selector("#group_order_articles_#{oa.id}")
    within("#group_order_articles_#{oa.id}") do
      # make sure these ordergroup names are in the list for this product
      expect(page).to have_content(go1.ordergroup_name)
      expect(page).to have_content(go2.ordergroup_name)
      # and that their order results match what we expect
      expect(page).to have_selector("#r_#{goa1.id}")
      expect(find("#r_#{goa1.id}").value.to_f).to eq(3)
      expect(page).to have_selector("#r_#{goa2.id}")
      expect(find("#r_#{goa2.id}").value.to_f).to eq(1)
    end
  end

  it 'keeps ordered quantities when article is deleted from resulting order' do
    within("#order_article_#{oa.id}") do
      click_link I18n.t('ui.delete')
    end
    expect(page).to_not have_selector("#order_article_#{oa.id}")
    expect(OrderArticle.exists?(oa.id)).to be true
    oa.reload
    expect(oa.quantity).to eq(4)
    expect(oa.tolerance).to eq(0)
    expect(oa.units_to_order).to eq(0)
    expect(goa1.reload.result).to eq(0)
    expect(goa2.reload.result).to eq(0)
  end

  it 'deletes an OrderArticle with no GroupOrderArticles' do
    goa1.destroy
    goa2.destroy
    within("#order_article_#{oa.id}") do
      click_link I18n.t('ui.delete')
    end
    expect(page).to_not have_selector("#order_article_#{oa.id}")
    expect(OrderArticle.exists?(oa.id)).to be false
  end

  it 'keeps ordered quantities when GroupOrderArticle is deleted from resulting order' do
    click_link article.name
    expect(page).to have_selector("#group_order_article_#{goa1.id}")
    within("#group_order_article_#{goa1.id}") do
      click_link I18n.t('ui.delete')
    end
    expect(page).to_not have_selector("#group_order_article_#{goa1.id}")
    expect(OrderArticle.exists?(oa.id)).to be true
    expect(GroupOrderArticle.exists?(goa1.id)).to be true
    goa1.reload
    expect(goa1.result).to eq(0)
    expect(goa1.quantity).to eq(3)
    expect(goa1.tolerance).to eq(0)
  end

  it 'deletes a GroupOrderArticle with no ordered amounts' do
    goa1.update_attributes({:quantity => 0, :tolerance => 0})
    click_link article.name
    expect(page).to have_selector("#group_order_article_#{goa1.id}")
    within("#group_order_article_#{goa1.id}") do
      click_link I18n.t('ui.delete')
    end
    expect(page).to_not have_selector("#group_order_article_#{goa1.id}")
    expect(OrderArticle.exists?(oa.id)).to be true
    expect(GroupOrderArticle.exists?(goa1.id)).to be false
  end

  it 'keeps product when amount is set to zero' do
    within("#order_article_#{oa.id}") do
      click_link I18n.t('ui.edit')
    end
    within("#edit_order_article_#{oa.id}") do
      fill_in :order_article_units_to_order, :with => 0
      find('input[type="submit"]').click
    end
    sleep 0.5 # workaround "javascript error" "e is null"
    expect(page).to have_selector("#order_article_#{oa.id}")
    # make sure it still works after reloading
    visit new_finance_order_path(order_id: order.id)
    expect(page).to have_selector("#order_article_#{oa.id}")
    expect(OrderArticle.exists?(oa.id)).to be true
    oa.reload
    expect(oa.units_to_order).to eq(0)
  end

  it 'can add an ordergroup to an order article' do
    user # need to reference user before "new article" dialog is loaded
    click_link article.name
    within("#group_order_articles_#{oa.id}") do
      click_link I18n.t('finance.balancing.group_order_articles.add_group')
    end
    expect(page).to have_selector('form#new_group_order_article')
    within('#new_group_order_article') do
      select user.ordergroup.name, :from => 'group_order_article_ordergroup_id'
      fill_in 'group_order_article_result', :with => 8
      find('input[type="submit"]').click
    end
    expect(page).to_not have_selector('form#new_group_order_article')
    expect(page).to have_content(user.ordergroup.name)
    goa = GroupOrderArticle.last
    expect(goa).to_not be_nil
    expect(goa.result).to eq 8
    expect(page).to have_selector("#group_order_article_#{goa.id}")
    expect(find("#r_#{goa.id}").value.to_f).to eq 8
  end

  it 'can modify an ordergroup result' do
    click_link article.name
    within("#group_order_articles_#{oa.id}") do
      fill_in "r_#{goa1.id}", :with => 5
    end
    expect(page).to have_selector('#summaryChangedWarning') # becomes visible after request is done
    expect(goa1.reload.result).to eq 5
    expect(find("#group_order_articles_#{oa.id} tfoot td:nth-child(3)").text.to_f).to eq 6
  end

  it 'can modify an ordergroup result using the + button' do
    click_link article.name
    within("#group_order_article_#{goa1.id}") do
      4.times { find('button[data-increment]').click }
    end
    expect(page).to have_selector('#summaryChangedWarning') # becomes visible after request is done
    expect(goa1.reload.result).to eq 7
    expect(find("#group_order_articles_#{oa.id} tfoot td:nth-child(3)").text.to_f).to eq 8
  end

  it 'can add an article' do
    new_article = create :article, supplier: supplier
    expect(page).to_not have_content(new_article.name)
    click_link I18n.t('finance.balancing.edit_results_by_articles.add_article')
    expect(page).to have_selector('form#new_order_article')
    within('#new_order_article') do
      select new_article.name, :from => 'order_article_article_id'
      find('input[type="submit"]').click
    end
    expect(page).to_not have_selector('form#new_order_article')
    expect(page).to have_content(new_article.name)
    expect(order.order_articles.where(article_id: new_article.id)).to_not be nil
  end
end
