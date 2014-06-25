require_relative '../spec_helper'

describe 'admin/configs', type: :feature do
  let(:name) { Faker::Lorem.words(rand(2..4)).join(' ') }

  describe type: :feature, js: true do
    let(:admin) { create :admin }
    before { login admin }

    it 'has initial value' do
      FoodsoftConfig[:name] = name
      visit admin_config_path
      within('form.config') do
        expect(find_field('config_name').value).to eq name
      end
    end

    it 'can modify a value' do
      visit admin_config_path
      fill_in 'config_name', with: name
      within('form.config') do
        find('input[type="submit"]').click
        expect(find_field('config_name').value).to eq name
      end
      expect(FoodsoftConfig[:name]).to eq name
    end

    it 'keeps config the same without changes' do
      orig_values = get_full_config
      visit admin_config_path
      within('form.config') do
        find('input[type="submit"]').click
        expect(find_field('config_name').value).to eq FoodsoftConfig[:name]
      end
      expect(get_full_config).to eq orig_values
    end

    def get_full_config
      cfg = FoodsoftConfig.to_hash.deep_dup
      cfg.each {|k,v| v.reject! {|k,v| v.blank?} if v.is_a? Hash}
      cfg
    end

  end
end
