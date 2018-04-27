class User::TalentTreesController < ApplicationController
  before_action :authorize_user

  def index
    if params.key?(:tree)
      if current_user.character.talent_trees.exists?(params[:tree].to_i)
        redirect_to user_talent_tree_path(params[:tree].to_i)
      else
        redirect_to user_talent_trees_path
      end
    else
      # FIXME: choose initial tree (app settings)
      redirect_to user_talent_tree_path(current_user.character.talent_trees.first)
    end
  end

  def show
    unless current_user.character.talent_trees.exists?(params[:id].to_i)
      redirect_to user_talent_trees_path
    end

    @groups = talent_tree_groups
    @tree = TalentTree.includes(:talents).find(params[:id])
  end

  def edit
    @tree = TalentTree.includes(:talents).find(params[:id])
  end

  def update
    @tree = TalentTree.find(params[:id])

    # Process image
    if params[:talent_tree].key?(:image)
      @tree.image = Base64.encode64(params[:talent_tree][:image].read)
    end

    # Process talent positions
    params[:talent_tree][:positions].each do |id, pos|
      @talent = TalentTreeTalent.find(id.to_i)
      @talent.pos_x = pos[:x].to_i
      @talent.pos_y = pos[:y].to_i
      @talent.save
    end

    if @tree.save && @tree.update(talent_tree_params)
      redirect_to edit_admin_talent_tree_path(@tree)
    else
      render 'edit' # TODO: errors -> view
    end
  end

  private

  def talent_tree_groups
    generic_tree_items =
      current_user.character.talent_trees.where.not(character_class_id: nil).or(
      current_user.character.talent_trees.where.not(specialization_id: nil)
    ).map do |tree|
      name = tree.specialization ? tree.specialization.name
                                 : tree.character_class.name
      [name, tree.id]
    end

    artifact_items =
      current_user.character.talent_trees.where.not(item_id: nil).map do |tree|
        [tree.item.name, tree.id]
      end

    individual_tree_items =
      current_user.character.talent_trees.where(character_class_id: nil,
                                                specialization_id: nil,
                                                item_id: nil).map do |tree|
                                                  [tree.id, tree.id] # FIXME
                                                end

    [
      ['Obecné stromy', generic_tree_items],
      ['Artefaktové zbraně', artifact_items],
      ['Individuální stromy', individual_tree_items],
    ]
  end

  def talent_tree_params
    params.require(:talent_tree).permit(:width, :height, :talent_size)
  end
end
