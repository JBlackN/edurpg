# Admin user permission settings controller
class Admin::PermissionsController < ApplicationController
  before_action :authorize_admin_manage_users

  def edit
    @user = User.find(params[:user_id])
    @permission = @user.permission
  end

  def update
    @permission = Permission.find(params[:id])

    if @permission.update(permission_params)
      redirect_to admin_users_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  private

  def permission_params
    params.require(:permission).permit(:use_app, :manage_users, :manage_app,
                                       :manage_attrs, :manage_achievement_categories,
                                       :manage_talent_trees, :manage_talents,
                                       :manage_quests, :manage_skills,
                                       :manage_achievements, :manage_items,
                                       :manage_titles)
  end
end
