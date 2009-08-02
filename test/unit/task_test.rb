# == Schema Information
#
# Table name: tasks
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)     default(""), not null
#  description    :string(255)
#  due_date       :date
#  done           :boolean(1)
#  workgroup_id   :integer(4)
#  assigned       :boolean(1)
#  created_on     :datetime        not null
#  updated_on     :datetime        not null
#  required_users :integer(4)      default(1)
#

require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase
  fixtures :tasks

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
