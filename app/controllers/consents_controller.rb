class ConsentsController < ApplicationController
  before_action :authorize

  def new
    @@page = render_to_string.html_safe
  end

  def create
    @consent = Consent.new(consent_params)
    @consent.page = @@page
    @consent.raw_post_data = request.raw_post
    @consent.save

    current_user.consents << @consent
    current_user.save

    redirect_to sessions_index_path
  end

  private

  def consent_params
    params.require(:consent).permit(:username, :name, :year, :study_plan,
                                    :grades, :titles, :roles, :classes,
                                    :events, :exams, :photo, :guilds)
  end
end
