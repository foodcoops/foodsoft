# == Schema Information
# Schema version: 20090317175355
#
# Table name: financial_transactions
#
#  id            :integer         not null, primary key
#  ordergroup_id :integer         default(0), not null
#  amount        :decimal(8, 2)   default(0.0), not null
#  note          :text            not null
#  user_id       :integer         default(0), not null
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
