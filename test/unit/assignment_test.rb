# == Schema Information
#
# Table name: assignments
#
#  id       :integer         not null, primary key
#  user_id  :integer         default(0), not null
#  task_id  :integer         default(0), not null
#  accepted :boolean
#

require File.dirname(__FILE__) + '/../test_helper'

class AssignmentTest < Test::Unit::TestCase
  fixtures :assignments

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
