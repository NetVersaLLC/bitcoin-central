require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = login_with(Factory(:user))
  end

  test "should render account editing form" do
    get :edit
    assert_response :success
  end

  test "should render account editing form for manager" do
    manager = Factory(:manager)
    sign_in(:user, manager)
    
    get :edit
    assert_response :success
  end
end
