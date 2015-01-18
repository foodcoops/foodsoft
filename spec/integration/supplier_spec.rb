# encoding: utf-8
require_relative '../spec_helper'

describe 'supplier', :type => :feature do
  let(:supplier) { create :supplier }

  describe :type => :feature, :js => true do
    let(:user) { create :user, groups:[create(:workgroup, role_suppliers: true)] }
    before { login user }

    it 'can be created' do
      visit suppliers_path
      click_on I18n.t('suppliers.index.action_new')
      supplier = build :supplier
      within('#new_supplier') do
        fill_in 'supplier_name', :with => supplier.name
        fill_in 'supplier_address', :with => supplier.address
        fill_in 'supplier_phone', :with => supplier.phone
        find('input[type="submit"]').click
      end
      expect(page).to have_content(supplier.name)
    end

    it 'is included in supplier list' do
      supplier
      visit suppliers_path
      expect(page).to have_content(supplier.name)
    end
  end

  describe :type => :feature, :js => true do
    let(:article_category) { create :article_category }
    let(:user) { create :user, groups:[create(:workgroup, role_article_meta: true)] }
    before { login user }

    it 'can visit supplier articles path' do
      visit supplier_articles_path(supplier)
      expect(page).to have_content(supplier.name)
      expect(page).to have_content(I18n.t('articles.index.edit_all'))
    end

    it 'can create a new article' do
      article_category.save!
      visit supplier_articles_path(supplier)
      click_on I18n.t('articles.index.new')
      expect(page).to have_selector('form#new_article')
      article = FactoryGirl.build :article, supplier: supplier, article_category: article_category
      within('#new_article') do
        fill_in 'article_name', :with => article.name
        fill_in 'article_unit', :with => article.unit
        select article.article_category.name, :from => 'article_article_category_id'
        fill_in 'article_price', :with => article.price
        fill_in 'article_unit_quantity', :with => article.unit_quantity
        fill_in 'article_tax', :with => article.tax
        fill_in 'article_deposit', :with => article.deposit
        # "Element cannot be scrolled into view" error, js as workaround
        #find('input[type="submit"]').click
        page.execute_script('$("form#new_article").submit();')
      end
      expect(page).to have_content(article.name)
    end


    Dir.glob('spec/fixtures/foodsoft_file_01.*') do |file|
      it "can import articles from #{file}" do
        article_category.save!
        visit upload_supplier_articles_path(supplier)
        attach_file 'articles_file', Rails.root.join(file)
        find('input[type="submit"]').click

        expect(find("tr:nth-child(1) #new_articles__note").value).to eq "bio ◎"
        expect(find("tr:nth-child(2) #new_articles__name").value).to eq "Pijnboompitten"

        4.times do |i|
          all("tr:nth-child(#{i+1}) select > option")[1].select_option
        end
        find('input[type="submit"]').click
        expect(page).to have_content("Pijnboompitten")

        expect(supplier.articles.count).to eq 4
      end
    end
  end

end
