# Admin achievement categories controller
class Admin::AchievementCategoriesController < ApplicationController
  before_action :authorize_admin, only: [:index, :show]
  before_action -> {
    authorize_admin_manage_achievement_categories(params[:id])
  }, except: [:index, :show]

  def index
    @categories = AchievementCategory.where(parent_id: nil)
    @codes = current_user.permission.class_restrictions.map do |cr|
      cr.code
    end
  end

  def show
    redirect_to admin_achievement_category_achievements_path(params[:id])
  end

  def new
    @categories = AchievementCategory.where(parent_id: nil)
    @category = AchievementCategory.new
    @codes = current_user.permission.class_restrictions.map do |cr|
      cr.code
    end
  end

  def edit
    @categories = AchievementCategory.where(parent_id: nil)
    @category = AchievementCategory.find(params[:id])
    @codes = current_user.permission.class_restrictions.map do |cr|
      cr.code
    end
  end

  def create
    @category = AchievementCategory.new(category_params)

    unless params[:achievement_category][:parent].empty?
      @category.parent_id = params[:achievement_category][:parent].to_i
    end

    if @category.save
      redirect_to admin_achievement_categories_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @category = AchievementCategory.find(params[:id])
    @category.name = params[:achievement_category][:name]

    unless params[:achievement_category][:parent].empty?
      @category.parent_id = params[:achievement_category][:parent].to_i
    else
      @category.parent_id = nil
    end

    if @category.save
      redirect_to admin_achievement_categories_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @category = AchievementCategory.find(params[:id])
    @category.destroy

    redirect_to admin_achievement_categories_path
  end

  private

  def category_params
    params.require(:achievement_category).permit(:name)
  end
end
