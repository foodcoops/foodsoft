require File.dirname(__FILE__) + '/../test_helper'
require 'finance_controller'

# Re-raise errors caught by the controller.
class FinanceController; def rescue_action(e) raise e end; end

class FinanceControllerTest < Test::Unit::TestCase
  def setup
    @controller = FinanceController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
