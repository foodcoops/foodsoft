# == Schema Information
#
# Table name: order_comments
#
#  id         :integer(4)      not null, primary key
#  order_id   :integer(4)
#  user_id    :integer(4)
#  text       :text
#  created_at :datetime
#

require 'test_helper'

class OrderCommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
