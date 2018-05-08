# User titles controller
class User::TitlesController < ApplicationController
  before_action :authorize_user

  def index
    @character_titles = current_user.character.character_titles
    @unobtained_titles = Title.all - current_user.character.titles
  end

  def update
    @character_title = CharacterTitle.find(params[:id])
    @character_title.active = !@character_title.active

    if @character_title.save
      redirect_to user_titles_path
    else
      render 'index' # TODO: errors -> view
    end
  end
end
