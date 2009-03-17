# == Schema Information
# Schema version: 20090317175355
#
# Table name: order_comments
#
#  id         :integer         not null, primary key
#  order_id   :integer
#  user_id    :integer
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
