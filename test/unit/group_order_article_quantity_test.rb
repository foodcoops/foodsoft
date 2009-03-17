# == Schema Information
# Schema version: 20090317175355
#
# Table name: group_order_article_quantities
#
#  id                     :integer         not null, primary key
#  group_order_article_id :integer         default(0), not null
#  quantity               :integer         default(0)
#  tolerance              :integer         default(0)
#  created_on             :datetime        not null
#

require File.dirname(__FILE__) + '/../test_helper'

class GroupOrderArticleQuantityTest < Test::Unit::TestCase
  fixtures :group_order_article_quantities

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
