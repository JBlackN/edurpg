require 'test_helper'

class Admin::AchiRewardsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_achi_rewards_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_achi_rewards_create_url
    assert_response :success
  end

end
