# == Schema Information
#
# Table name: orders
#
#  id                 :integer(4)      not null, primary key
#  supplier_id        :integer(4)
#  note               :text
#  starts             :datetime
#  ends               :datetime
#  state              :string(255)     default("open")
#  lock_version       :integer(4)      default(0), not null
#  updated_by_user_id :integer(4)
#  foodcoop_result    :decimal(8, 2)
#

require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
