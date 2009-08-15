# == Schema Information
#
# Table name: articles
#
#  id                  :integer         not null, primary key
#  name                :string(255)     default(""), not null
#  supplier_id         :integer         default(0), not null
#  article_category_id :integer         default(0), not null
#  unit                :string(255)     default(""), not null
#  note                :string(255)
#  availability        :boolean         default(TRUE), not null
#  manufacturer        :string(255)
#  origin              :string(255)
#  shared_updated_on   :datetime
#  price               :decimal(, )
#  tax                 :float
#  deposit             :decimal(, )     default(0.0)
#  unit_quantity       :integer         default(1), not null
#  order_number        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  quantity            :integer         default(0)
#  deleted_at          :datetime
#  type                :string(255)
#

require 'test_helper'

class StockArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
