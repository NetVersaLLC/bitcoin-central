require 'test_helper'

class GauthControllerTest < ActionController::TestCase

  def setup
    @user = login_with(Factory(:user))
  end

  test "should reset google auth otp" do
    old_token = @user.ga_otp_secret

    get :reset
    assert_response :redirect
    assert_redirected_to gauth_path

    assert_not_equal old_token, @user.reload.ga_otp_secret
  end

  test "should show google auth otp configuration page" do
    get :index
    assert_response :success
  end
end