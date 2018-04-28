class User::TalentsController < ApplicationController
  before_action :authorize_user
  before_action -> {
    authorize_user_manage_talent_tree(params[:talent_tree_id])
  }
  before_action -> {
    authorize_user_manage_talent_tree_talent(params[:id])
  }, except: [:new, :create]

  def new
    @tree = TalentTree.find(params[:talent_tree_id])
  end

  def edit
    @tree = TalentTree.find(params[:talent_tree_id])
    @tree_talent = TalentTreeTalent.find(params[:id])
    @talent = @tree_talent.talent
  end

  def create
    @tree = TalentTree.find(params[:talent_tree_id])
    @talent = Talent.find_by(code: params[:talent][:code])

    unless @talent
      @talent = Talent.new(talent_params)

      # Process image
      if params[:talent].key?(:image)
        @talent.image = Base64.encode64(params[:talent][:image].read)
      end
    end

    if @talent.save
      # Asign to tree
      @tree.talent_tree_talents << TalentTreeTalent.new(talent: @talent,
                                                        pos_x: params[:talent][:pos_x].to_i,
                                                        pos_y: params[:talent][:pos_y].to_i)

      redirect_to edit_user_talent_tree_path(@tree)
    else
      render 'new' # TODO: errors -> view
    end
  end

  def update
    @tree = TalentTree.find(params[:talent_tree_id])
    @talent = TalentTreeTalent.find(params[:id]).talent

    # Process image
    if params[:talent].key?(:image)
      @talent.image = Base64.encode64(params[:talent][:image].read)
    end

    if @talent.save && @talent.update(talent_params)
      redirect_to edit_user_talent_tree_path(@tree)
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

    redirect_to edit_user_talent_tree_path(@tree)
  end

  private

  def talent_params
    params.require(:talent).permit(:name, :description, :points, :code)
  end
end
