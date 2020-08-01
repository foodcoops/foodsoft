# encoding: utf-8
require_relative '../spec_helper'

feature 'supplier' do
  let(:supplier) { create :supplier }

  describe 'create new' do
    let(:user) { create :user, groups:[create(:workgroup, role_suppliers: true)] }
    before { login user }

    it 'can be created' do
      create :supplier_category
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
end
