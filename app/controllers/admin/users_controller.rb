class Admin::UsersController < ApplicationController
  def index
    @users = User.all
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
end
