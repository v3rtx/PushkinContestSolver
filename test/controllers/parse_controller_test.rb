require 'test_helper'

class ParseControllerTest < ActionController::TestCase
  test "should get do" do
    get :do
    assert_response :success
  end

end
