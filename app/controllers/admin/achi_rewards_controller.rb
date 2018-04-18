class Admin::AchiRewardsController < ApplicationController
  before_action :authorize_admin_manage_achievements

  def new
    @achievement = Achievement.find(params[:achievement_id])
    @items = Item.all
    @titles = Title.all
  end

  def create
    @category = AchievementCategory.find(params[:achievement_category_id])
    @achievement = Achievement.find(params[:achievement_id])

    @achievement.items.clear
    @achievement.titles.clear

    if params.key?(:items)
      params[:items].each do |item_id, value|
        item_id = item_id.to_i
        value = value.to_i == 1 ? true : false
        @achievement.items << Item.find(item_id) if value
      end
    end

    if params.key?(:titles)
      params[:titles].each do |title_id, value|
        title_id = title_id.to_i
        value = value.to_i == 1 ? true : false
        @achievement.titles << Title.find(title_id) if value
      end
    end

    if @achievement.save
      redirect_to edit_admin_achievement_category_achievement_path(@category, @achievement)
    else
      render 'new' # TODO: errors -> view
    end
  end
end
