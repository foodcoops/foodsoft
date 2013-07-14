require 'spec_helper'

describe Supplier do
  let(:supplier) { FactoryGirl.create :supplier }

  it 'has a unique name' do
    supplier2 = FactoryGirl.build :supplier, name: supplier.name
    supplier2.should_not be_valid
  end

  it 'has valid articles' do
    supplier = FactoryGirl.create :supplier, article_count: true
    supplier.articles.all.should be_valid
  end

end
