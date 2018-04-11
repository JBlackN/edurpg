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

  def authorize_admin_manage_attrs
    unless current_user.permission.manage_attrs
      redirect_to admin_character_attributes_index_path
    end
  end

  def authorize_admin_manage_skills
    unless current_user.permission.manage_skills
      redirect_to admin_character_attribute_skills_index_path
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
