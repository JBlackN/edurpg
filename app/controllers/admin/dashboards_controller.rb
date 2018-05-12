# Admin dashboard controller
#
# Currently also initializes application on first admin login.
class Admin::DashboardsController < ApplicationController
  before_action :authorize_admin

  def index
    redirect_to admin_initializer_index_path if !CharacterClass.any? || DelayedJob.any?
  end
end
