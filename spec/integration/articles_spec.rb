require_relative '../spec_helper'
require_relative '../support/active_record_helper'

feature ArticlesController do
  let(:user) { create(:user, groups: [create(:workgroup, role_article_meta: true)]) }
  let(:supplier) { create(:supplier) }
  let!(:article_unit) { create(:article_unit, unit: 'XPK') }
  let!(:article_category) { create(:article_category) }

  before do
    login user
    create(:article_unit, unit: 'XPP')
  end

  describe ':index', :js do
    let!(:existing_article) do
      create(:article,
             supplier: supplier,
             supplier_order_unit: 'B22',
             group_order_unit: 'B22',
             billing_unit: 'B22',
             price_unit: 'B22',
             article_unit_ratio_count: 0)
    end

    before do
      visit supplier_articles_path(supplier_id: supplier.id)
    end

    it 'can visit supplier articles path' do
      expect(page).to have_content(supplier.name)
      expect(page).to have_content(I18n.t('articles.index.edit_all'))
    end

    describe 'creating articles' do
      it 'can create a new article' do
        click_on I18n.t('articles.index.new')
        expect(page).to have_css('form#new_article_version')
        article_version = build(:article_version, supplier_order_unit: article_unit.unit)
        within('#new_article_version') do
          fill_in 'article_version_name', with: article_version.name
          select article_category.name, from: 'article_version_article_category_id'
          fill_in 'article_version_price', with: article_version.price
          unit_label = ArticleUnitsLib.units[article_version.supplier_order_unit][:name]
          select unit_label, from: 'article_version_supplier_order_unit'
          fill_in 'article_version_tax', with: article_version.tax
          fill_in 'article_version_deposit', with: article_version.deposit
          find('input[type="submit"]:enabled').click
        end
        expect(page).to have_content(article_version.name)
      end

      it 'provides units that have been added to article_units' do
        create(:article_unit, unit: 'KGM')
        create(:article_unit, unit: 'LTR')

        click_on I18n.t('articles.index.new')
        expect(page).to have_css('form#new_article_version')
        expect(page).to have_select('article_version_supplier_order_unit', options: ['Custom', 'kilogram (kg)', 'litre (l)', 'Package', 'Piece'])
      end
    end

    describe 'editing articles' do
      it 'can edit an existing article' do
        find("*[data-e2e-edit-article='#{existing_article.id}']").click
        expect(page).to have_css("form#edit_article_version_#{existing_article.id}")
        within("#edit_article_version_#{existing_article.id}") do
          fill_in 'article_version_name', with: 'New name'
          sleep 0.25 # <- unsure why this is required as the following line should wait for the button to be enabled:
          find('input[type="submit"]:enabled').click
        end

        expect(page).to have_content('New name')
      end

      it 'provides units that have been added to article_units as well as those in the article being edited' do
        create(:article_unit, unit: 'KGM')
        create(:article_unit, unit: 'LTR')

        find("*[data-e2e-edit-article='#{existing_article.id}']").click
        expect(page).to have_css("form#edit_article_version_#{existing_article.id}")
        expect(page).to have_select('article_version_supplier_order_unit', options: ['Custom', 'kiloampere (kA)', 'kilogram (kg)', 'litre (l)', 'Package', 'Piece'])
      end
    end
  end

  describe ':sync', :js do
    let(:remote_supplier) { create(:supplier, external_uuid: 'TestUUID', article_count: 10) }

    before do
      supplier.update(
        supplier_remote_source: api_v1_shared_supplier_articles_url(remote_supplier.external_uuid,
                                                                    foodcoop: FoodsoftConfig[:default_scope],
                                                                    host: Capybara.current_session.server.host,
                                                                    port: Capybara.current_session.server.port),
        shared_sync_method: 'all_available'
      )
    end

    it 'imports articles from external suppliers' do
      visit supplier_articles_path(supplier_id: supplier.id)
      click_on I18n.t('articles.index.ext_db.sync')
      expect(page).to have_css('.sync-table tbody tr', count: 10)

      10.times do |index|
        select ArticleCategory.first.name, from: "new_articles_#{index}_article_category_id"
      end

      click_on I18n.t('articles.sync.submit')
      expect(page).to have_css('.just-updated.article', count: 10)
    end

    it 'synchronizes articles updated in external supplier' do
      clone_supplier_articles(remote_supplier, supplier)

      first_remote_article_version = remote_supplier.articles.first.latest_article_version
      first_remote_article_version.name = 'Changed'
      first_remote_article_version.save

      visit supplier_articles_path(supplier_id: supplier.id)
      click_on I18n.t('articles.index.ext_db.sync')
      expect(page).to have_css '.sync-table tbody tr',
                               count: 2 # 1 row for original + 1 row for changed version

      click_on I18n.t('articles.sync.submit')
      expect(page).to have_css('.just-updated.article', count: 1)
    end
  end

  describe ':upload' do
    let(:filename) { 'foodsoft_file_02.csv' }
    let(:file)     { Rails.root.join("spec/fixtures/#{filename}") }

    before do
      create(:article_category, name: 'Nuts & Seeds')
      create(:article_category, name: 'Drinks')
      create(:article_category, name: 'Vegetables')
      visit upload_supplier_articles_path(supplier_id: supplier.id)
      attach_file 'articles_file', file
    end

    Dir.glob('spec/fixtures/foodsoft_file_01.*') do |test_file|
      describe "can import articles from #{test_file}" do
        let(:file) { Rails.root.join(test_file) }

        it do
          find('input[type="submit"]').click
          expect(find('tr:nth-child(1) #new_articles_0_note').value).to eq 'bio ◎'
          expect(find('tr:nth-child(2) #new_articles_1_name').value).to eq 'Pijnboompitten'

          find('input[type="submit"]').click
          expect(page).to have_content('Pijnboompitten')

          expect(supplier.articles.count).to eq 4
        end
      end
    end

    describe 'can update existing article' do
      let!(:article) { create(:article, supplier: supplier, name: 'Foobar', order_number: 1, unit: '250 g', group_order_unit: nil, price_unit: nil) }

      it do
        find('input[type="submit"]').click
        expect(find_by_id('articles_0_name').value).to eq 'Tomatoes'
        expect(find_by_id('articles_0_id', visible: false).value).to eq article.latest_article_version.id.to_s
        find('input[type="submit"]').click
        article.reload
        expect(article.name).to eq 'Tomatoes'
        expect([article.unit, article.unit_quantity, article.price]).to eq ['500 g', 20, 1.2]
      end
    end

    describe 'handles missing data' do
      it do
        find('input[type="submit"]').click # to overview
        fill_in 'new_articles_0_name', with: ''
        find('input[type="submit"]').click # missing name, re-show form
        expect(find('tr.alert')).to be_present
        expect(supplier.articles.count).to eq 0

        fill_in 'new_articles_0_name', with: 'Test'
        find('input[type="submit"]').click # now it should succeed
        expect(supplier.articles.count).to eq 1
      end
    end

    describe 'can remove an existing article' do
      let!(:article) { create(:article, supplier: supplier, name: 'Foobar', order_number: 99_999) }

      it do
        check('articles_outlist_absent')
        find('input[type="submit"]').click
        expect(find_by_id('outlisted_articles_0', visible: :all).value).to eq article.id.to_s

        find('input[type="submit"]').click
        expect(article.reload.deleted?).to be true
      end
    end

    describe 'can convert units when updating' do
      let!(:article) { create(:article, supplier: supplier, order_number: 1, unit: '250 g', group_order_unit: nil, price_unit: nil) }

      it do
        check('articles_convert_units')
        find('input[type="submit"]').click
        expect(find_by_id('articles_0_name').value).to eq 'Tomatoes'
        find('input[type="submit"]').click
        article.reload
        expect([article.unit, article.unit_quantity, article.price]).to eq ['250 g', 40, 0.6]
      end
    end
  end
end
