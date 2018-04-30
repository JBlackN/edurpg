class Admin::SkillsController < ApplicationController
  before_action :authorize_admin_manage_skills, except: [:index]
  before_action :authorize_admin, only: [:index]

  def index
    @attribute = CharacterAttribute.find(params[:character_attribute_id])
    @attributes = CharacterAttribute.all - [@attribute]
  end

  def new
    @attribute = CharacterAttribute.find(params[:character_attribute_id])
  end

  def edit
    @attribute = CharacterAttribute.find(params[:character_attribute_id])
    @skill = Skill.find(params[:id])
    @skills = @attribute.skills - [@skill]
  end

  def create
    @skill = Skill.new(skill_params)

    # Normalize skill rank
    ranks = Skill.where(name: @skill.name).map do |skill|
      skill.rank
    end
    min_rank = ((1..ranks.max+1).to_a - ranks).first rescue 1
    @skill.rank = min_rank if @skill.rank > min_rank

    # Process image
    if params[:skill].key?(:image)
      @skill.image = img_encode_base64(params[:skill][:image])
    end

    # Asign attribute
    @skill.character_attribute_id = params[:character_attribute_id]

    if @skill.save
      redirect_to admin_character_attribute_skills_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @skill = Skill.find(params[:id])

    # Normalize skill rank
    ranks = Skill.where(name: @skill.name).map do |skill|
      skill.rank
    end - [@skill.rank]
    min_rank = ((1..ranks.max+1).to_a - ranks).first rescue 1
    @skill.rank = min_rank if params[:skill][:rank].to_i > min_rank

    # Process image
    if params[:skill].key?(:image)
      @skill.image = img_encode_base64(params[:skill][:image])
    end

    if @skill.save && @skill.update(skill_params_update)
      redirect_to admin_character_attribute_skills_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @skill = Skill.find(params[:id])
    @skill.destroy

    redirect_to admin_character_attribute_skills_path
  end

  private

  def skill_params
    params.require(:skill).permit(:name, :description, :rank)
  end

  def skill_params_update
    params.require(:skill).permit(:name, :description)
  end
end
