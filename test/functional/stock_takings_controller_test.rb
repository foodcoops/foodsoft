require 'test_helper'

class StockTakingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_takings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_taking" do
    assert_difference('StockTaking.count') do
      post :create, :stock_taking => { }
    end

    assert_redirected_to stock_taking_path(assigns(:stock_taking))
  end

  test "should show stock_taking" do
    get :show, :id => stock_takings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => stock_takings(:one).id
    assert_response :success
  end

  test "should update stock_taking" do
    put :update, :id => stock_takings(:one).id, :stock_taking => { }
    assert_redirected_to stock_taking_path(assigns(:stock_taking))
  end

  test "should destroy stock_taking" do
    assert_difference('StockTaking.count', -1) do
      delete :destroy, :id => stock_takings(:one).id
    end

    assert_redirected_to stock_takings_path
  end
end
