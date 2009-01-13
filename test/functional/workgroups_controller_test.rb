require 'test_helper'

class WorkgroupsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workgroups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workgroup" do
    assert_difference('Workgroup.count') do
      post :create, :workgroup => { }
    end

    assert_redirected_to workgroup_path(assigns(:workgroup))
  end

  test "should show workgroup" do
    get :show, :id => workgroups(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => workgroups(:one).id
    assert_response :success
  end

  test "should update workgroup" do
    put :update, :id => workgroups(:one).id, :workgroup => { }
    assert_redirected_to workgroup_path(assigns(:workgroup))
  end

  test "should destroy workgroup" do
    assert_difference('Workgroup.count', -1) do
      delete :destroy, :id => workgroups(:one).id
    end

    assert_redirected_to workgroups_path
  end
end
