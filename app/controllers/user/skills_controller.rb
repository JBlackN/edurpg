# User skills controller
class User::SkillsController < ApplicationController
  before_action :authorize_user

  def index
    @attributes = CharacterAttribute.all
  end

  def show
    @attribute = CharacterAttribute.find(params[:id])
    @attributes = CharacterAttribute.all - [@attribute]
    @character_skills = current_user.character.skills.where(character_attribute: @attribute)
    @unobtained_skills = @attribute.skills - @character_skills
  end
end
