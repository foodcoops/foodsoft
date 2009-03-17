# == Schema Information
# Schema version: 20090317175355
#
# Table name: article_prices
#
#  id            :integer         not null, primary key
#  article_id    :integer
#  price         :decimal(8, 2)   default(0.0), not null
#  tax           :decimal(8, 2)   default(0.0), not null
#  deposit       :decimal(8, 2)   default(0.0), not null
#  unit_quantity :integer
#  created_at    :datetime
#

require 'test_helper'

class ArticlePriceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
