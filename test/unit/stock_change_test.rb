require 'test_helper'

class StockChangeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: stock_changes
#
#  id               :integer(4)      not null, primary key
#  delivery_id      :integer(4)
#  order_id         :integer(4)
#  stock_article_id :integer(4)
#  quantity         :integer(4)      default(0)
#  created_at       :datetime
#  stock_taking_id  :integer(4)
#

