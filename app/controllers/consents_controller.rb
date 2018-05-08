# Consents controller
class ConsentsController < ApplicationController
  before_action :authorize, only: [:new, :create]
  before_action -> {
    authorize_consent_edit(params[:id])
  }, only: [:edit, :update]

  def new
    @@page = render_to_string.html_safe
  end

  def edit
    @consent = Consent.find(params[:id])
    @email = "#{current_user.username}@fit.cvut.cz"
  end

  def create
    @consent = Consent.new(consent_params)
    @consent.page = @@page
    @consent.raw_post_data = request.raw_post
    @consent.save

    current_user.consents << @consent
    current_user.save

    if current_user.character
      current_user.character.name =
        if @consent.name
          Usermap.get_user_name(current_user.username, session[:user]['token'])
        else
          'Anonym'
        end
      current_user.character.save

      if @consent.photo
        sent = send_photo_consent_mail
        if sent
          redirect_to edit_consent_path(@consent) 
          return
        else
          @consent.photo = false
          @consent.save
        end
      end
    end

    redirect_to sessions_index_path
  end

  def update
    @consent = Consent.find(params[:id])

    # If user inputted valid one-time authorization code for photo consent
    # confirm the consent and load user's photo from Usermap.
    if params.key?(:consent) && params[:consent].key?(:code) &&
       !params[:consent][:code].nil? && !params[:consent][:code].empty? &&
       current_user.authenticate_otp(params[:consent][:code], drift: 600)
      @consent.photo = true
      current_user.character.image =
        Usermap.get_user_photo(current_user.username, session[:user]['token'])
      current_user.character.image = '' if current_user.character.image.nil?
      current_user.character.save
    else
      @consent.photo = false
    end

    @consent.save
    redirect_to sessions_index_path
  end

  private

  def consent_params
    params.require(:consent).permit(:username, :name, :grades, :info,
                                    :roles, :classes, :photo, :guilds)
  end
end
