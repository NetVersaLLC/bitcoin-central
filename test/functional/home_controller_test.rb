require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get frontpage" do
    get :welcome
    assert_response :success
  end
end
