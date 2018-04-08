class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    if User.any?
      if User.find_by(username: auth['uid'])
        set_session(auth)
        redirect_to 'permissions#update'
      else
      end
    else
      @user = User.new(username: auth['uid'])
      if @user.save
        set_session(auth)
        redirect_to 'permissions#create'
      else
        redirect_to root_path
      end
    end
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
