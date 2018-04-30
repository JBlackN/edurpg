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

    if current_user.character
      current_user.character.name =
        if @consent.name
          Usermap.get_user_name(current_user.username, session[:user]['token'])
        else
          'Anonym'
        end
      current_user.character.image =
        if @consent.photo
          Usermap.get_user_photo(current_user.username, session[:user]['token'])
        else
          nil
        end
      current_user.character.save
    end

    current_user.consents << @consent
    current_user.save

    redirect_to sessions_index_path
  end

  private

  def consent_params
    params.require(:consent).permit(:username, :name, :grades, :info,
                                    :roles, :classes, :photo, :guilds)
  end
end
