class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def authorize
    redirect_to :login unless user_signed_in?
  end

  def authorize_user
    redirect_to :login unless current_user.permission.use_app
  end

  def authorize_admin
    redirect_to :login unless current_user.permission.manage_app ||
      current_user.permission.manage_attrs ||
      current_user.permission.manage_achievement_categories ||
      current_user.permission.manage_talent_trees ||
      current_user.permission.manage_talents ||
      current_user.permission.manage_quests ||
      current_user.permission.manage_skills ||
      current_user.permission.manage_achievements ||
      current_user.permission.manage_items ||
      current_user.permission.manage_titles
  end

  def authorize_admin_manage_users
    unless current_user.permission.manage_users
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_attrs
    unless current_user.permission.manage_attrs
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_achievement_categories(category_id = nil)
    if current_user.permission.manage_achievement_categories
      unless category_id.nil?
        if current_user.permission.class_restrictions.any?
          code = AchievementCategory.find(category_id).code
          unless code.nil?
            unless current_user.permission.class_restrictions.exists?(code: code)
              redirect_back fallback_location: root_path
            end
          end
        end
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_talent_trees
    unless current_user.permission.manage_talent_trees
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_talents(talent_tree_talent_id = nil)
    if current_user.permission.manage_talents
      unless talent_tree_talent_id.nil?
        if current_user.permission.class_restrictions.any?
          code = TalentTreeTalent.find(talent_tree_talent_id).talent.code
          unless current_user.permission.class_restrictions.exists?(code: code)
            redirect_back fallback_location: root_path
          end
        end
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_quests
    unless current_user.permission.manage_quests
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_skills
    unless current_user.permission.manage_skills
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_achievements
    unless current_user.permission.manage_achievements
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_items
    unless current_user.permission.manage_items
      redirect_back fallback_location: root_path
    end
  end

  def authorize_admin_manage_titles
    unless current_user.permission.manage_titles
      redirect_back fallback_location: root_path
    end
  end

  def current_user
    @current_user ||= User.find_by(
      username: session[:user]['name']) unless session[:user].nil?
  end

  def user_signed_in?
    !!current_user
  end
end
