require_relative '../spec_helper'

describe TokenVerifier do
  let(:prefix) { 'xyz' }
  let(:v) { TokenVerifier.new(prefix) }
  let(:msg) { v.generate }

  it 'validates' do
    expect { v.verify(msg) }.to_not raise_error
  end

  it 'validates when recreated' do
    v2 = TokenVerifier.new(prefix)
    expect { v2.verify(msg) }.to_not raise_error
  end

  it 'does not validate with a different prefix' do
    v2 = TokenVerifier.new('abc')
    expect { v2.verify(msg) }.to raise_error(TokenVerifier::InvalidPrefix)
  end

  it 'does not validate in a different foodcoop scope' do
    msg
    oldscope = FoodsoftConfig.scope
    begin
      FoodsoftConfig.scope = Faker::Lorem.words(number: 1)
      v2 = TokenVerifier.new(prefix)
      expect { v2.verify(msg) }.to raise_error(TokenVerifier::InvalidScope)
    ensure
      FoodsoftConfig.scope = oldscope
    end
  end

  it 'does not validate a random string' do
    expect { v.verify(Faker::Lorem.characters(number: 100)) }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
  end

  it 'returns the message' do
    data = [5, { 'hi' => :there }, 'bye', []]
    msg = v.generate(data)
    expect(v.verify(msg)).to eq data
  end
end
