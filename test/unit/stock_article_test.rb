require 'test_helper'

class StockArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: articles
#
#  id                  :integer(4)      not null, primary key
#  name                :string(255)     default(""), not null
#  supplier_id         :integer(4)      default(0), not null
#  article_category_id :integer(4)      default(0), not null
#  unit                :string(255)     default(""), not null
#  note                :string(255)
#  availability        :boolean(1)      default(TRUE), not null
#  manufacturer        :string(255)
#  origin              :string(255)
#  shared_updated_on   :datetime
#  price               :decimal(8, 2)
#  tax                 :float
#  deposit             :decimal(8, 2)   default(0.0)
#  unit_quantity       :integer(4)      default(1), not null
#  order_number        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  type                :string(255)
#  quantity            :integer(4)      default(0)
#

