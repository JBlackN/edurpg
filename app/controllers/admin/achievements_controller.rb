require 'base64'

class Admin::AchievementsController < ApplicationController
  def index
    @category = AchievementCategory.find(params[:achievement_category_id])
    @categories = AchievementCategory.where(parent_id: nil)
  end

  def new
    @category = AchievementCategory.find(params[:achievement_category_id])
  end

  def edit
    @category = AchievementCategory.find(params[:achievement_category_id])
    @achievement = Achievement.find(params[:id])
    @achievements = @category.achievements - [@achievement]
  end

  def create
    @achievement = Achievement.new(achi_params)

    # Process image
    @achievement.image = Base64.encode64(params[:achievement][:image].read)

    # Asign attribute
    @achievement.achievement_category_id = params[:achievement_category_id]

    if @achievement.save
      redirect_to admin_achievement_category_achievements_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @achievement = Achievement.find(params[:id])

    # Process image
    if params[:achievement].key?(:image)
      @achievement.image = Base64.encode64(params[:achievement][:image].read)
    end

    if @achievement.save && @achievement.update(achi_params)
      redirect_to admin_achievement_category_achievements_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @achievement = Achievement.find(params[:id])
    @achievement.destroy

    redirect_to admin_achievement_category_achievements_path
  end

  private

  def achi_params
    params.require(:achievement).permit(:name, :description, :points)
  end
end
