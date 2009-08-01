# == Schema Information
#
# Table name: financial_transactions
#
#  id            :integer(4)      not null, primary key
#  ordergroup_id :integer(4)      default(0), not null
#  amount        :decimal(8, 2)   default(0.0), not null
#  note          :text            default(""), not null
#  user_id       :integer(4)      default(0), not null
#  created_on    :datetime        not null
#

require File.dirname(__FILE__) + '/../test_helper'

class FinancialTransactionTest < Test::Unit::TestCase
  fixtures :financial_transactions

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
