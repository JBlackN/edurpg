class SessionsController < ApplicationController
  before_action :authorize, only: :index

  def index
    render plain: 'session#index'
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
