# == Schema Information
# Schema version: 20090317175355
#
# Table name: stock_changes
#
#  id               :integer         not null, primary key
#  delivery_id      :integer
#  order_id         :integer
#  stock_article_id :integer
#  quantity         :integer         default(0)
#  created_at       :datetime
#  stock_taking_id  :integer
#

require 'test_helper'

class StockChangeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
