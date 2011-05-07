require 'test_helper'

class ArticlePriceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: article_prices
#
#  id            :integer(4)      not null, primary key
#  article_id    :integer(4)
#  price         :decimal(8, 2)   default(0.0), not null
#  tax           :decimal(8, 2)   default(0.0), not null
#  deposit       :decimal(8, 2)   default(0.0), not null
#  unit_quantity :integer(4)
#  created_at    :datetime
#

