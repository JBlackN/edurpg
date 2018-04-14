require 'test_helper'

class Admin::QuestRewardsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get admin_quest_rewards_edit_url
    assert_response :success
  end

end
