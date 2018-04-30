class Admin::UsersController < ApplicationController
  before_action :authorize_admin_manage_users, only: [:index]
  before_action :authorize_admin, except: [:index]

  def index
    @users = User.all
  end

  def show
    respond_to do |format|
      format.html { redirect_to edit_admin_user_path(current_user) }
      format.json { send_data data_for_export,
                    type: :json, disposition: 'attachment' }
    end
  end

  def edit
    @character = current_user.character
  end

  def update
    @character = current_user.character
    @character.name = params[:character][:name]

    # Process image
    if params[:character].key?(:image)
      @character.image = Base64.encode64(params[:character][:image].read)
    end

    if @character.save
      redirect_to edit_admin_user_path(current_user)
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    current_user.destroy
    redirect_to :logout
  end

  private

  def data_for_export
    data = current_user.to_json(
      include: [
        :permission,
        :consents,
        {
          character: {
            include: {
              quests: {
                include: [
                  :character_class,
                  :specialization,
                  :talent,
                  :skills,
                  :achievements,
                  :items,
                  :titles
                ]
              }
            }
          }
        }
      ]
    )
    data
  end
end
