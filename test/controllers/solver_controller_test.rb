require 'test_helper'

class SolverControllerTest < ActionController::TestCase
  test "should get quiz" do
    get :quiz
    assert_response :success
  end

  test "should get quiz2" do
    get :quiz2
    assert_response :success
  end

  test "should get reg" do
    get :reg
    assert_response :success
  end

end
