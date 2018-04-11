class Admin::CharacterAttributesController < ApplicationController
  before_action :authorize_admin_manage_attrs, except: [:index, :show]
  before_action :authorize_admin, only: [:index, :show]

  def index
    @attributes = CharacterAttribute.all
  end

  def show
    redirect_to admin_character_attribute_skills_path(params[:id])
  end

  def new
    @attributes = CharacterAttribute.all
    @attribute = CharacterAttribute.new
  end

  def edit
    @attribute = CharacterAttribute.find(params[:id])
    @attributes = CharacterAttribute.all - [@attribute]
  end

  def create
    @attribute = CharacterAttribute.new(attribute_params)

    if @attribute.save
      redirect_to admin_character_attributes_path
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @attribute = CharacterAttribute.find(params[:id])

    if @attribute.update(attribute_params)
      redirect_to admin_character_attributes_path
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @attribute = CharacterAttribute.find(params[:id])
    @attribute.destroy

    redirect_to admin_character_attributes_path
  end

  private

  def attribute_params
    params.require(:character_attribute).permit(:name)
  end
end
