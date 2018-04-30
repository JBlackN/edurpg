class Admin::TalentsController < ApplicationController
  before_action :authorize_admin_manage_talent_trees
  before_action :authorize_admin_manage_talents, only: [:new, :create]
  before_action -> {
    authorize_admin_manage_talents(params[:id])
  }, except: [:new, :create]

  def new
    @tree = TalentTree.find(params[:talent_tree_id])
    @attributes = CharacterAttribute.all
  end

  def edit
    @tree = TalentTree.find(params[:talent_tree_id])
    @tree_talent = TalentTreeTalent.find(params[:id])
    @talent = @tree_talent.talent
    @attributes = CharacterAttribute.all
  end

  def create
    @tree = TalentTree.find(params[:talent_tree_id])
    @talent = Talent.find_by(code: params[:talent][:code])

    unless @talent
      @talent = Talent.new(talent_params)

      # Process image
      if params[:talent].key?(:image)
        @talent.image = img_encode_base64(params[:talent][:image])
      end

      # Process attributes
      if params[:talent].key?(:attributes)
        params[:talent][:attributes].each do |attribute_id, points|
          @talent.add_attribute(CharacterAttribute.find(attribute_id), points)
        end
      end
    end

    if @talent.save
      # Asign to tree
      @tree.talent_tree_talents << TalentTreeTalent.new(talent: @talent,
                                                        pos_x: params[:talent][:pos_x].to_i,
                                                        pos_y: params[:talent][:pos_y].to_i)

      redirect_to edit_admin_talent_tree_path(@tree)
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @tree = TalentTree.find(params[:talent_tree_id])
    @talent = TalentTreeTalent.find(params[:id]).talent

    # Process image
    if params[:talent].key?(:image)
      @talent.image = img_encode_base64(params[:talent][:image])
    end

    # Process attributes
    if params[:talent].key?(:attributes)
      @talent.talent_attributes.clear
      params[:talent][:attributes].each do |attribute_id, points|
        @talent.add_attribute(CharacterAttribute.find(attribute_id), points)
      end
    end

    if @talent.save && @talent.update(talent_params)
      redirect_to edit_admin_talent_tree_path(@tree)
    else
      render 'edit' # TODO: errors -> view
    end
  end

  def destroy
    @tree = TalentTree.find(params[:talent_tree_id])
    @tree_talent = TalentTreeTalent.find(params[:id])
    @talent = @tree_talent.talent
    @tree_talent.destroy

    # Destroy talent if not in any tree
    @talent.destroy unless @talent.talent_tree_talents.any?

    redirect_to edit_admin_talent_tree_path(@tree)
  end

  private

  def talent_params
    params.require(:talent).permit(:name, :description, :points, :code)
  end
end
