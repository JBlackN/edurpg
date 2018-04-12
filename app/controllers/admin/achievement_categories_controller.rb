class Admin::AchievementCategoriesController < ApplicationController
  before_action :authorize_admin_manage_achievement_categories,
    except: [:index, :show]
  before_action :authorize_admin, only: [:index, :show]

  def index
    courses_category = AchievementCategory.find_by(name: 'Předměty')

    if courses_category.nil?
      courses = Kos.get_courses(session[:user]['token'])

      courses_category = AchievementCategory.create(name: 'Předměty')
      courses_bi_category = courses_category.subcategories.create(
        name: 'Bakalářské')
      courses_mi_category = courses_category.subcategories.create(
        name: 'Magisterské')

      courses[:bi].each do |name|
        courses_bi_category.subcategories.create(name: name)
      end

      courses[:mi].each do |name|
        courses_mi_category.subcategories.create(name: name)
      end
    end

    @categories = AchievementCategory.where(parent_id: nil)
  end

  def show
    redirect_to admin_achievement_category_achievements_path(params[:id])
  end

  def new
    @categories = AchievementCategory.where(parent_id: nil)
    @category = AchievementCategory.new
  end

  def edit
    @categories = AchievementCategory.where(parent_id: nil)
    @category = AchievementCategory.find(params[:id])
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
