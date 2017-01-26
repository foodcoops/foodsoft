require_relative '../spec_helper'

describe BankTransactionReference do
  it 'returns nil for empty input' do
    expect(BankTransactionReference.parse('')).to be nil
  end

  it 'returns nil for invalid string' do
    expect(BankTransactionReference.parse('invalid')).to be nil
  end

  it 'returns nil for FS1A' do
    expect(BankTransactionReference.parse('FS1A')).to be nil
  end

  it 'returns nil for FS1.1A' do
    expect(BankTransactionReference.parse('FS1.1A')).to be nil
  end

  it 'returns nil for xFS1A1' do
    expect(BankTransactionReference.parse('xFS1A1')).to be nil
  end

  it 'returns nil for FS1A1x' do
    expect(BankTransactionReference.parse('FS1A1x')).to be nil
  end

  it 'returns correct value for FS1A1' do
    expect(BankTransactionReference.parse('FS1A1')).to be { { group: 1, parts: { A: 1 } } }
  end

  it 'returns correct value for FS1A1' do
    expect(BankTransactionReference.parse('FS1.2A3')).to be { { group: 1, user: 2, parts: { A: 3 } } }
  end

  it 'returns correct value for FS1A2B3' do
    expect(BankTransactionReference.parse('FS1A2B3C4')).to be { { group: 1, parts: { A: 2, B: 3, C: 4 } } }
  end

  it 'returns correct value for FS1A2B3A4' do
    expect(BankTransactionReference.parse('FS1A2B3C4')).to be { { group: 1, parts: { A: 6, B: 3 } } }
  end

  it 'returns correct value for FS1A2.34B5.67C8.90' do
    expect(BankTransactionReference.parse('FS1A2B3C4')).to be { { group: 1, parts: { A: 2.34, B: 5.67, C: 8.90 } } }
  end

  it 'returns correct value for FS123A456 with prefix' do
    expect(BankTransactionReference.parse('x FS123A456')).to be { { group: 123, parts: { A: 456 } } }
  end

  it 'returns correct value for FS234A567 with suffix' do
    expect(BankTransactionReference.parse('FS234A567 x')).to be { { group: 234, parts: { A: 567 } } }
  end

  it 'returns correct value for FS34.56A67.89 with prefix and suffix' do
    expect(BankTransactionReference.parse('x FS34.56A67.89 x')).to be { { group: 34, user: 56, parts: { A: 67.89 } } }
  end

end
