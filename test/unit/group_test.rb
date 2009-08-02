# == Schema Information
#
# Table name: groups
#
#  id                  :integer(4)      not null, primary key
#  type                :string(255)     default(""), not null
#  name                :string(255)     default(""), not null
#  description         :string(255)
#  account_balance     :decimal(8, 2)   default(0.0), not null
#  account_updated     :datetime
#  created_on          :datetime        not null
#  role_admin          :boolean(1)      not null
#  role_suppliers      :boolean(1)      not null
#  role_article_meta   :boolean(1)      not null
#  role_finance        :boolean(1)      not null
#  role_orders         :boolean(1)      not null
#  weekly_task         :boolean(1)
#  weekday             :integer(4)
#  task_name           :string(255)
#  task_description    :string(255)
#  task_required_users :integer(4)      default(1)
#  deleted_at          :datetime
#  contact_person      :string(255)
#  contact_phone       :string(255)
#  contact_address     :string(255)
#  stats               :text
#

require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
