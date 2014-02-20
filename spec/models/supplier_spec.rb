require_relative '../spec_helper'

describe Supplier do
  let(:supplier) { create :supplier }

  it 'has a unique name' do
    supplier2 = build :supplier, name: supplier.name
    expect(supplier2).to be_invalid
  end

  it 'has valid articles' do
    supplier = create :supplier, article_count: true
    supplier.articles.each {|a| expect(a).to be_valid }
  end

end
