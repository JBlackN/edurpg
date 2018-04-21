require 'test_helper'

class User::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_dashboards_index_url
    assert_response :success
  end

end
