class User::AchievementsController < ApplicationController
  before_action :authorize_user

  def index
    @categories = AchievementCategory.where(parent_id: nil)
    @codes = codes
  end

  def show
    @codes = codes
    @category = AchievementCategory.find(params[:id])
    @categories = AchievementCategory.where(parent_id: nil)
    @character_achievements = current_user.character.achievements.where(
      achievement_category: @category)
    @unobtained_achievements = @category.achievements - @character_achievements
  end

  private

  def codes
    if current_user.consents.first.classes
      @codes ||= Kos.get_student_courses(current_user.username,
                                         session[:user]['token']).map do |course|
        course['code']
      end
    else
      []
    end
  end
end
