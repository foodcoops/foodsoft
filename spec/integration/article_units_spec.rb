require_relative '../spec_helper'

feature ArticleUnitsController do
  let(:user) { create(:user, groups: [create(:workgroup, role_article_meta: true)]) }

  before do
    login user
    create(:article_unit, unit: 'XPP')
  end

  describe ':index', :js do
    before { visit article_units_path }

    it 'displays units that have already been added along with their translations' do
      expect(page).to have_content(/piece/i)
    end

    it 'does not display units that have already been added along with their translations' do
      expect(page).to have_no_content(/kilogram/i)
    end

    it 'allows searching for recommended (translated) units that have not been added yet' do
      check 'only_recommended'
      fill_in 'article_unit_search', with: 'kilogram'
      expect(page).to have_content(/kilogram/i)
    end

    it 'does not return search results for units that have neither been added nor translated unless the "only recommended" checkbox is unchecked' do
      check 'only_recommended'
      fill_in 'article_unit_search', with: 'kiloampere'
      expect(page).to have_no_content(/kiloampere/i)

      uncheck 'only_recommended'

      expect(page).to have_content(/kiloampere/i)
    end

    it 'allows adding units' do
      fill_in 'article_unit_search', with: 'kilogram'
      expect(page).to have_content(/kilogram/i)

      find('*[data-e2e-create-unit="KGM"]').click

      # reset search...:
      fill_in 'article_unit_search', with: ''
      page.has_content?('piece')

      # ... kilogram should *still* be there if it has been added successfully:
      expect(page).to have_content(/kilogram/i)
    end

    it 'allows deleting units' do
      accept_confirm do
        find('*[data-e2e-destroy-unit="XPP"]').click
      end

      expect(page).to have_css('.alert-success')

      # the unit is still displayed (even if not in the search scope) in case the user wants to re-add it:
      expect(page).to have_content(/piece/i)
      expect(page).to have_css('a[data-e2e-create-unit="XPP"]')
    end
  end
end
