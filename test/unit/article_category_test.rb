# == Schema Information
# Schema version: 20090317175355
#
# Table name: article_categories
#
#  id          :integer         not null, primary key
#  name        :string(255)     default(""), not null
#  description :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class ArticleCategoryTest < Test::Unit::TestCase
  fixtures :article_categories

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
