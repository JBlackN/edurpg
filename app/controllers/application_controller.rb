class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def authorize
    puts "#{user_signed_in?}"
    redirect_to :login unless user_signed_in?
  end

  def current_user
    @current_user ||= User.find_by(
      username: session[:user]['name']) unless session[:user].nil?
  end

  def user_signed_in?
    !!current_user
  end
end
