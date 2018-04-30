class Admin::AchievementsController < ApplicationController
  before_action :authorize_admin, only: [:index]
  before_action :authorize_admin_manage_achievements, except: [:index]
  before_action -> {
    authorize_admin_manage_achievement_categories(params[:achievement_category_id])
  }, except: [:index]

  def index
    @category = AchievementCategory.find(params[:achievement_category_id])
    @categories = AchievementCategory.where(parent_id: nil)
    @codes = current_user.permission.class_restrictions.map do |cr|
      cr.code
    end
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
    if params[:achievement].key?(:image)
      @achievement.image = img_encode_base64(params[:achievement][:image])
    end

    # Asign category
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
      @achievement.image = img_encode_base64(params[:achievement][:image])
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
