require_relative '../spec_helper'

describe FoodsoftConfig do
  let(:name) { Faker::Lorem.words(number: rand(2..4)).join(' ') }
  let(:other_name) { Faker::Lorem.words(number: rand(2..4)).join(' ') }

  it 'returns a default value' do
    expect(FoodsoftConfig[:protected][:database]).to be true
  end

  it 'returns an empty default value' do
    expect(FoodsoftConfig[:protected][:LIUhniuyGNKUQTWfbiOQIWYexngo78hqexul]).to be nil
  end

  it 'returns a configuration value' do
    FoodsoftConfig.config[:name] = name
    expect(FoodsoftConfig[:name]).to eq name
  end

  it 'can set a configuration value' do
    FoodsoftConfig[:name] = name
    expect(FoodsoftConfig[:name]).to eq name
  end

  it 'can override a configuration value' do
    FoodsoftConfig.config[:name] = name
    FoodsoftConfig[:name] = other_name
    expect(FoodsoftConfig[:name]).to eq other_name
  end

  it 'cannot set a default protected value' do
    old = FoodsoftConfig[:database]
    FoodsoftConfig[:database] = name
    expect(FoodsoftConfig.config[:database]).to eq old
  end

  it 'can unprotect a default protected value' do
    FoodsoftConfig.config[:protected][:database] = false
    old = FoodsoftConfig[:database]
    FoodsoftConfig[:database] = name
    expect(FoodsoftConfig[:database]).to eq name
  end

  describe 'can protect a value', type: :feature do
    before do
      FoodsoftConfig.config[:protected][:name] = true
    end

    it 'can protect a value' do
      old_name = FoodsoftConfig[:name]
      FoodsoftConfig[:name] = name
      expect(FoodsoftConfig[:name]).to eq old_name
    end

    it 'and unprotect it again' do
      old_name = FoodsoftConfig[:name]
      FoodsoftConfig.config[:protected][:name] = false
      FoodsoftConfig[:name] = name
      expect(FoodsoftConfig[:name]).to eq name
    end
  end

  it 'can protect all values' do
    old_name = FoodsoftConfig[:name]
    FoodsoftConfig.config[:protected][:all] = true
    FoodsoftConfig[:name] = name
    expect(FoodsoftConfig[:name]).to eq old_name
  end

  it 'can whitelist a value' do
    FoodsoftConfig.config[:protected][:all] = true
    FoodsoftConfig.config[:protected][:name] = false
    FoodsoftConfig[:name] = name
    expect(FoodsoftConfig[:name]).to eq name
  end

  describe 'has indifferent access', type: :feature do
    it 'with symbol' do
      FoodsoftConfig[:name] = name
      expect(FoodsoftConfig[:name]).to eq FoodsoftConfig['name']
    end

    it 'with string' do
      FoodsoftConfig['name'] = name
      expect(FoodsoftConfig['name']).to eq FoodsoftConfig[:name]
    end

    it 'with nested symbol' do
      FoodsoftConfig[:protected][:database] = true
      expect(FoodsoftConfig[:protected]['database']).to eq FoodsoftConfig[:protected][:database]
    end

    it 'with nested string' do
      FoodsoftConfig[:protected]['database'] = true
      expect(FoodsoftConfig[:protected]['database']).to eq FoodsoftConfig[:protected][:database]
    end
  end

end
