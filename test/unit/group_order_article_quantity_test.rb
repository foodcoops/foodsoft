require File.dirname(__FILE__) + '/../test_helper'

class GroupOrderArticleQuantityTest < Test::Unit::TestCase
  fixtures :group_order_article_quantities

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: group_order_article_quantities
#
#  id                     :integer(4)      not null, primary key
#  group_order_article_id :integer(4)      default(0), not null
#  quantity               :integer(4)      default(0)
#  tolerance              :integer(4)      default(0)
#  created_on             :datetime        not null
#

