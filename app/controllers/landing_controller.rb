class LandingController < ApplicationController
  def index
    redirect_to sessions_index_path unless session[:user].nil?
  end
end
