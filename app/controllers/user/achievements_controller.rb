# User achievements controller
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

  def update
    @achievement = Achievement.find(params[:id])

    if current_user.character.achievements.exists?(@achievement.id)
      # Mark unachieved
      @character_achievement =
        current_user.character.character_achievements.find_by(
          achievement_id: @achievement.id)
      current_user.character.character_achievements.destroy(@character_achievement)

      # Take item rewards from user (unless they're awarded by another
      # achieved achievement or completed quest)
      @achievement.items.each do |item|
        if character_item = current_user.character.character_items.find_by(
            item_id: item.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.items.exists?(item.id)
          } || current_user.character.achievements.any? { |achi|
            achi.items.exists?(item.id)
          }
            current_user.character.character_items.destroy(character_item)
          end
        end
      end

      # Take title rewards from user (unless they're awarded by another
      # achieved achievement or completed quest)
      @achievement.titles.each do |title|
        if character_title = current_user.character.character_titles.find_by(
            title_id: title.id)
          unless current_user.character.completed_quests.any? { |quest|
            quest.titles.exists?(title.id)
          } || current_user.character.achievements.any? { |achi|
            achi.titles.exists?(title.id)
          }
            current_user.character.character_titles.destroy(character_title)
          end
        end
      end
    else
      # Mark achieved
      unless current_user.character.achievements.exists?(@achievement.id)
        current_user.character.achievements << @achievement
      end

      # Give item rewards to user (unless already given)
      @achievement.items.each do |item|
        unless current_user.character.items.exists?(item.id)
          current_user.character.items << item
        end
      end

      # Give title rewards to user (unless already given)
      @achievement.titles.each do |title|
        unless current_user.character.titles.exists?(title.id)
          current_user.character.titles << title
        end
      end
    end

    redirect_to user_achievement_path(@achievement.achievement_category.id)
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
