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
    render plain: params.inspect
  end
end
