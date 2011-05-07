require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: pages
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  body         :text
#  permalink    :string(255)
#  lock_version :integer(4)      default(0)
#  updated_by   :integer(4)
#  redirect     :integer(4)
#  parent_id    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

