# == Schema Information
#
# Table name: memberships
#
#  id       :integer         not null, primary key
#  group_id :integer         default(0), not null
#  user_id  :integer         default(0), not null
#

require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < Test::Unit::TestCase
  fixtures :memberships

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
