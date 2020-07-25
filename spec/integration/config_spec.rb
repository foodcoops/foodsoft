require_relative '../spec_helper'

feature 'admin/configs' do
  let(:name) { Faker::Lorem.words(number: rand(2..4)).join(' ') }
  let(:email) { Faker::Internet.email }
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

  it 'can modify a nested value' do
    visit admin_config_path
    fill_in 'config_contact_email', with: email
    within('form.config') do
      find('input[type="submit"]').click
      expect(find_field('config_contact_email').value).to eq email
    end
    expect(FoodsoftConfig[:contact][:email]).to eq email
  end

  def get_full_config
    cfg = FoodsoftConfig.to_hash.deep_dup
    compact_hash_deep!(cfg)
  end

  def compact_hash_deep!(h)
    h.each do |k,v|
      if v.is_a? Hash
        compact_hash_deep!(v)
        v.reject! {|k,v| v.blank?}
      end
    end
    h.reject! {|k,v| v.blank?}
    h
  end
end
