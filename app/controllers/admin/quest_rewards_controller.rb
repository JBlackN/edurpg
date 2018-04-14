class Admin::QuestRewardsController < ApplicationController
  def new
    @quest = Quest.find(params[:quest_id])
    @skills = Skill.all
    @achievements = Achievement.all
    @items = Item.all
    @titles = Title.all
  end

  def create
    @quest = Quest.find(params[:quest_id])

    if @quest.quest_exp_reward
      @quest.quest_exp_reward.destroy
    end
    @quest.skills.clear
    @quest.achievements.clear
    @quest.items.clear
    @quest.titles.clear

    if !params[:exp].empty? && params[:exp].to_i > 0
      @quest.create_quest_exp_reward(points: params[:exp].to_i)
    end

    if params.key?(:skills)
      params[:skills].each do |skill_id, value|
        skill_id = skill_id.to_i
        value = value.to_i == 1 ? true : false
        @quest.skills << Skill.find(skill_id) if value
      end
    end

    if params.key?(:achievements)
      params[:achievements].each do |achievement_id, value|
        achievement_id = achievement_id.to_i
        value = value.to_i == 1 ? true : false
        @quest.achievements << Achievement.find(achievement_id) if value
      end
    end

    if params.key?(:items)
      params[:items].each do |item_id, value|
        item_id = item_id.to_i
        value = value.to_i == 1 ? true : false
        @quest.items << Item.find(item_id) if value
      end
    end

    if params.key?(:titles)
      params[:titles].each do |title_id, value|
        title_id = title_id.to_i
        value = value.to_i == 1 ? true : false
        @quest.titles << Title.find(title_id) if value
      end
    end

    if @quest.save
      redirect_to edit_admin_quest_path(@quest)
    else
      render 'new' # TODO: errors -> view
    end
  end
end
