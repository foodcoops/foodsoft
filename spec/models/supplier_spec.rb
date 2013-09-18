require 'spec_helper'

describe Supplier do
  let(:supplier) { FactoryGirl.create :supplier }

  it 'has a unique name' do
    supplier2 = FactoryGirl.build :supplier, name: supplier.name
    expect(supplier2).to be_invalid
  end

  it 'has valid articles' do
    supplier = FactoryGirl.create :supplier, article_count: true
    supplier.articles.all.each {|a| expect(a).to be_valid }
  end

end
