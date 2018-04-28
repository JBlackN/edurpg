require 'test_helper'

class User::GuildsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_guilds_show_url
    assert_response :success
  end

end
