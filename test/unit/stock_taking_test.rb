# == Schema Information
# Schema version: 20090317175355
#
# Table name: stock_takings
#
#  id         :integer         not null, primary key
#  date       :date
#  note       :text
#  created_at :datetime
#

require 'test_helper'

class StockTakingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
