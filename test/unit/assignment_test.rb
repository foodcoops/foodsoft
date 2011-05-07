require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < Test::Unit::TestCase
  fixtures :assignments

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end


# == Schema Information
#
# Table name: assignments
#
#  id       :integer(4)      not null, primary key
#  user_id  :integer(4)      default(0), not null
#  task_id  :integer(4)      default(0), not null
#  accepted :boolean(1)      default(FALSE)
#

