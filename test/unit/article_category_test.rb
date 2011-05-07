require File.dirname(__FILE__) + '/../test_helper'

class ArticleCategoryTest < Test::Unit::TestCase
  fixtures :article_categories

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: article_categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     default(""), not null
#  description :string(255)
#

