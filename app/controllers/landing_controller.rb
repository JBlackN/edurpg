# Landing page controller
class LandingController < ApplicationController
  def index
    redirect_to sessions_index_path unless session[:user].nil?
    # else render login page
  end
end
