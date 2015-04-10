# encoding: utf-8
require_relative '../spec_helper'

describe ArticlesController, :type => :feature do
  let(:user) { create :user, groups:[create(:workgroup, role_article_meta: true)] }
  let (:supplier) { create :supplier }
  let!(:article_category) { create :article_category }
  before { login user }

  describe ":index", :type => :feature, :js => true do
    before { visit supplier_articles_path(supplier) }

    it 'can visit supplier articles path' do
      expect(page).to have_content(supplier.name)
      expect(page).to have_content(I18n.t('articles.index.edit_all'))
    end

    it 'can create a new article' do
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
  end

  describe ":upload", :type => :feature, :js => true do
    let(:filename) { 'foodsoft_file_02.csv' }
    let(:file)     { Rails.root.join("spec/fixtures/#{filename}") }
    before do
      visit upload_supplier_articles_path(supplier)
      attach_file 'articles_file', file
    end

    Dir.glob('spec/fixtures/foodsoft_file_01.*') do |test_file|
      describe "can import articles from #{test_file}" do
        let(:file) { Rails.root.join(test_file) }
        it do
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

    describe "can update existing article" do
      let!(:article) { create :article, supplier: supplier, name: 'Foobar', order_number: 1 }
      it do
        find('input[type="submit"]').click
        expect(find("#articles_#{article.id}_name").value).to eq 'Tomatoes'
        find('input[type="submit"]').click
        expect(article.reload.name).to eq 'Tomatoes'
      end
    end

    describe "handles missing data" do
      it do
        find('input[type="submit"]').click # to overview
        find('input[type="submit"]').click # missing category, re-show form
        expect(find('tr.alert')).to be_present
        expect(supplier.articles.count).to eq 0

        all("tr select > option")[1].select_option
        find('input[type="submit"]').click # now it should succeed
        expect(supplier.articles.count).to eq 1
      end
    end

    describe "can remove an existing article" do
      let!(:article) { create :article, supplier: supplier, name: 'Foobar', order_number: 99999 }
      it do
        check('articles_outlist_absent')
        find('input[type="submit"]').click
        expect(find("#outlisted_articles_#{article.id}", visible: :all)).to be_present

        all("tr select > option")[1].select_option
        find('input[type="submit"]').click
        expect(article.reload.deleted?).to be true
      end
    end
  end
end
