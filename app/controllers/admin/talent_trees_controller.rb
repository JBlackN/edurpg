class Admin::TalentTreesController < ApplicationController
  def index
    @classes = CharacterClass.all
    @items = Item.joins(:talent_tree).where(rarity: 'artifact')
  end

  def edit
    @classes = CharacterClass.all
    @items = Item.joins(:talent_tree).where(rarity: 'artifact')
    @tree = TalentTree.includes(:talents).find(params[:id])
  end

  def update
    @tree = TalentTree.find(params[:id])

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

  def talent_tree_params
    params.require(:talent_tree).permit(:width, :height, :talent_size)
  end
end
