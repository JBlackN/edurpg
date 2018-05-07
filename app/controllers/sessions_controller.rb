class SessionsController < ApplicationController
  before_action :authorize, only: :index

  def index
    if current_user.consent_invalid?
      redirect_to '/consents/new'
    elsif !current_user.consents.first.username ||
          !current_user.consents.first.roles
      current_user.destroy
      redirect_to :logout
    elsif current_user.character.nil?
      current_user.build_character
      current_user.character.init(session[:user]['token'])
      current_user.save
      redirect_to sessions_index_path
    elsif current_user.consents.first.photo &&
          current_user.character.image.nil?
      sent = send_photo_consent_mail
      current_user.character.image = ''
      current_user.character.save
      if sent
        redirect_to edit_consent_path(current_user.consents.first)
      else
        consent = current_user.consents.first
        consent.photo = false
        consent.save
        redirect_to sessions_index_path
      end
    elsif current_user.admin_only?
      redirect_to admin_dashboards_index_path
    elsif current_user.user_only?
      redirect_to user_dashboards_index_path
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
      redirect_to root_path unless perms && @user.save
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
