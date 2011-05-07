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
#  id           :integer         not null, primary key
#  title        :string(255)
#  body         :text
#  permalink    :string(255)
#  lock_version :integer         default(0)
#  updated_by   :integer
#  redirect     :integer
#  parent_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#

