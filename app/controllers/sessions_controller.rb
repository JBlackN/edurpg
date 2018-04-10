class SessionsController < ApplicationController
  before_action :authorize, only: :index

  def index
    puts "#{current_user.only_admin?}"
    puts "#{current_user.only_user?}"
    if current_user.consent_invalid?
      redirect_to '/consents/new'
    elsif current_user.only_admin?
      redirect_to admin_dashboards_index_path
    elsif current_user.only_user?
      redirect_to dashboards_index_path
    end
  end

  def create
    db_empty = !User.any?
    auth = request.env['omniauth.auth']
    @user = User.find_by(username: auth['uid'])

    if @user.nil?
      @user = User.new(username: auth['uid'])
      @user.build_permission
      perms = @user.permission.assign(db_empty, auth['credentials']['token'])
      redirect_to root_path unless perms
      redirect_to root_path unless @user.save
    else
      perms = @user.permission.refresh(auth['credentials']['token'])
      redirect_to root_path unless perms
    end

    set_session(auth)
    redirect_to sessions_index_path
  end

  def destroy
    session[:user] = nil
    redirect_to root_path
  end

  private

  def set_session(auth)
    session[:user] = {
      name: auth['uid'],
      token: auth['credentials']['token']
    }
  end
end
